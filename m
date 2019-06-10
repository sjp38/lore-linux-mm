Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6923C31E40
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 16:58:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B41682085A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 16:58:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B41682085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 544926B026E; Mon, 10 Jun 2019 12:58:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F4766B0270; Mon, 10 Jun 2019 12:58:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40BC76B0271; Mon, 10 Jun 2019 12:58:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A0676B026E
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 12:58:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d27so16233367eda.9
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 09:58:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=clft74qbZO62hEal4dSLELVBC7mEIeYaPY9YqR93Pvo=;
        b=FCAm+OswY9/y3ZkSox2fJ+6dM4skpq8SegjxnTCjWIiTxYUqNv85y1ObWktJpC+r3B
         84zQAW2tD+lw2H8NmItuUs5zNqrYZdtLA8MavPl+Fac1QCwyS+4Kj77cVINPYol14Eh3
         HPGtMHE7hwZrudw5JMUoT8Ls7MLubk2IwZ+y9RG2i6NRITPmm6K9MdfsI6ohLbnmnBfV
         n3Og1D4kVl46aY5kozaPU5RI8EOXIW0fFRLLbXNMZpNPSrvmFzA3PoHhJzOg+f+Vu9Dd
         ZssQXuWIdbJfJT0o7ODxfTeTCXfgL0JoejMKQoFAkVVPEEGRLU5il5n1+L2D9/qsafWb
         QJ+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAW1fl0blvoIZIENto82zPBc0Y1zq7rGNhR9qPHCAgdpsdadja0U
	YmU73ZVTm7sY64LDvyhWG6+1NJaaBOpU5SE7EQDO9jpw547nDk09lUP4tUst8mq0D2k2XVOqifP
	sTLgSSJe/nvUB8hJslUrNToGYSmtC4JQsK3R+Cuq3EbW+4zsOWPnEzwThucwVX0Yd6w==
X-Received: by 2002:a17:906:27d9:: with SMTP id k25mr19631044ejc.194.1560185918621;
        Mon, 10 Jun 2019 09:58:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+nO8sUmP6Jf2nHdgL1zOayb006vvcARCf02yofoGMWYOgmyOf77AD0tddyI9m7v/ukvnF
X-Received: by 2002:a17:906:27d9:: with SMTP id k25mr19630998ejc.194.1560185917939;
        Mon, 10 Jun 2019 09:58:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560185917; cv=none;
        d=google.com; s=arc-20160816;
        b=nVRThy+cuUyVrh4gDCeRPIgZhGf+XHKnYGLuJLDfzY0aMYm6pSbOPsxNgNCrNMscUN
         HM66U0nqhDgm9iLsYqx5nFAdKZcK5qDxIsuFcVs9+Z2kFLcPJDyjx4Dd2BjlkVNLgwyL
         CX8X3Ka5QPMzx81x78xQbIVBdeGClHR7MW8Suj+LhVoHUGZbRXUw26/4fSLqcl4dtXCM
         5Aijt71nHaEOKPxNyGUaWf3QbNo5txStyp0vcThpeavAwrb3LCA7HsivJ8xWI7irMp9O
         FOEy9esp97CJdn8nrxgbt0Sa42Jl+NeYgsY7Vuzt3JOur3FzehQLbC7xJZ9/VxRai4W/
         Y/Zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=clft74qbZO62hEal4dSLELVBC7mEIeYaPY9YqR93Pvo=;
        b=vGGviAtyxz06UztH1idEToYm76C42ZdveT5beJgcHHTsWsvYYqbWui6JkcvPXytxNm
         3nAGxc2rHh09y42k62R8iF1u+aZUHl0BjI/LQkDzMiP3YL6fotVOo3y74wHhiXkLW89n
         JLQkL8576vNx0tE0dzueNs4AdW/G4i01yhhCykabqJcwU6JuVi+aDbbj4jJJFF+H9Zs2
         BxiGCa76ms/ZYMbpQIPtD4rgJIJLPQQ/9TFKfi6++9l7FS8Wn+9Ryycfm+GY59L043F0
         z2N3exXBVbUZ8xQQAAUHCtQxAwsreK3G4iKPP57dTIir13bHfxZi2yj8Jru4un/jETF6
         GjHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ec4si6739376ejb.68.2019.06.10.09.58.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 09:58:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7B3A4AC3A;
	Mon, 10 Jun 2019 16:58:37 +0000 (UTC)
Date: Mon, 10 Jun 2019 18:58:35 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>
Subject: Re: [PATCH v3 11/11] mm/memory_hotplug: Remove "zone" parameter from
 sparse_remove_one_section
Message-ID: <20190610165834.GC5643@linux>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-12-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-12-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 01:11:52PM +0200, David Hildenbrand wrote:
> The parameter is unused, so let's drop it. Memory removal paths should
> never care about zones. This is the job of memory offlining and will
> require more refactorings.
> 
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

