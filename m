Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 855FEC76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:46:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56A9021849
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:46:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56A9021849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E431A8E0006; Thu, 18 Jul 2019 16:46:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF4748E0001; Thu, 18 Jul 2019 16:46:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE38A8E0006; Thu, 18 Jul 2019 16:46:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id ACCE78E0001
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 16:46:49 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id u17so7301845vsq.17
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 13:46:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=PmvHfIU1snVh89UcQi+Sq1c9QWttmkQpviWD068MVdc=;
        b=EDZt5t6+ba7V3ueopSw2rPHxZlj8ba7bjhjUDZVOxaHdiB71aCk+bfDDNLHV8MzvxN
         taeX2k7YL14tBtp5RC1IqFU+Z8lhpENfnD37iR6RUeft5v3jJw1bxEj760SgE2ZYJnor
         LYfTWxYNsLbAbIloGL/kLyHPhIW6ZlFOOegWvtK++tssDgzr7kGV9isDYdBgLTxq//jX
         rwJssO5AzfHVHxFF9+x/0l4POJL6iLom4flATeb3z3xMJxMl1ZqcfGGUFYIZWP9jufHF
         AuNA4KMdw4bwizar4oIyfbcFBbq16uqEk55hI2xL+cK2SVXV5EB3DYbyd93+jWgv8GZZ
         G3hw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXW3wwr/xDnXaiIC30FsgU0o+Qz78Mh/HuNWgHhapyUzzSRsfic
	jyQyzLT7c+pw3jzuNd28pGzbu1hXa1G16aM4cLc7wFwMH9inha++v3eDQnJ8OMJCKEEwRTBsBfL
	Msyp7SR/TcKcfhxmxYG6he+7ADj1ifcD2deMcPE5Hf64oqb8QCBKhAr/zlWY7QKDUzw==
X-Received: by 2002:a67:2bc4:: with SMTP id r187mr30149908vsr.102.1563482809480;
        Thu, 18 Jul 2019 13:46:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRMlYyUEbEzWkp5C/jedfMNzXhsSHAXFi7gDZlJPtpONZjFlSKVXkDa3dyZAzWvWhL9Lbx
X-Received: by 2002:a67:2bc4:: with SMTP id r187mr30149881vsr.102.1563482809055;
        Thu, 18 Jul 2019 13:46:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563482809; cv=none;
        d=google.com; s=arc-20160816;
        b=lKBLq3uI6s2rdhdByPsIwYjEXA7SFSbhSmvJfeSiMb42QfxxSSDAQUz/IKO6T5vh+J
         EiA6xlKFb6qDO7VH7H6ghCfmO7L1dNmm1YVE8Gi4LfSNN0pA0VXor3Ke66EAmSx3l2SS
         cQihvOuf+UrNFqY1HCbRCfAob9ECyHUKDIQqtXgZhmjSbIRzEaUvj/S4ExQE+NMZI+sm
         5Is1W5znDbNbvRHD7KeyFH9RrdKBnV/u/dzFTvd7Np5bBdszA/MmiBIsRlc5g75H/kgg
         spyzWfU88e/8aH8PtyI88lCfs83C7h8xHew6mUGdvVcT/G36PS9i1whW1z0db1b0JHWw
         xeww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=PmvHfIU1snVh89UcQi+Sq1c9QWttmkQpviWD068MVdc=;
        b=oZ3cHvpfNjmdY6kVriHunjGDA89LKn00XKgyqVT3Dg5iGkFwXHNtXMcNJJWhfY8A4j
         NBtr0bRaVSWYjUwfP0DDlmgZJI2ZE4/MCcgmkzO+zE2xh2v1Ga35TUEcJwq6rmK49Dt2
         WiBxEhE2148d6/nDzAjGWO+3lBAMgp2j9O+aKrVWLIIQyMcC6w4VpqppWJSsTZ8woBS6
         dzZpwmkgO/4yF437YsRvHwxQgtxcyHwjkyNhyWaC9axfnj6chYc8sdcG/OtkjsY1BV28
         wOt3E3k4xfXWsP+eguoykfhhcA4brdDKQUwzyOQn6sjSDv4P880ExOgcNtSyBQl4j7YX
         Fp7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l16si6897976uao.70.2019.07.18.13.46.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 13:46:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3F70630C135E;
	Thu, 18 Jul 2019 20:46:48 +0000 (UTC)
Received: from redhat.com (ovpn-120-147.rdu2.redhat.com [10.10.120.147])
	by smtp.corp.redhat.com (Postfix) with SMTP id 17F2560920;
	Thu, 18 Jul 2019 20:46:29 +0000 (UTC)
Date: Thu, 18 Jul 2019 16:46:28 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Wang <wei.w.wang@intel.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	xdeguillard@vmware.com, namit@vmware.com, pagupta@redhat.com,
	riel@surriel.com, dave.hansen@intel.com, david@redhat.com,
	konrad.wilk@oracle.com, yang.zhang.wz@gmail.com, nitesh@redhat.com,
	lcapitulino@redhat.com, aarcange@redhat.com, pbonzini@redhat.com,
	alexander.h.duyck@linux.intel.com, dan.j.williams@intel.com
Subject: Re: [PATCH v2] mm/balloon_compaction: avoid duplicate page removal
Message-ID: <20190718164550-mutt-send-email-mst@kernel.org>
References: <1563442040-13510-1-git-send-email-wei.w.wang@intel.com>
 <20190718082535-mutt-send-email-mst@kernel.org>
 <20190718133626.e30bec8fc506689b3daf48ee@linux-foundation.org>
 <20190718164152-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190718164152-mutt-send-email-mst@kernel.org>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Thu, 18 Jul 2019 20:46:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 04:42:50PM -0400, Michael S. Tsirkin wrote:
> On Thu, Jul 18, 2019 at 01:36:26PM -0700, Andrew Morton wrote:
> > On Thu, 18 Jul 2019 08:26:11 -0400 "Michael S. Tsirkin" <mst@redhat.com> wrote:
> > 
> > > On Thu, Jul 18, 2019 at 05:27:20PM +0800, Wei Wang wrote:
> > > > Fixes: 418a3ab1e778 (mm/balloon_compaction: List interfaces)
> > > > 
> > > > A #GP is reported in the guest when requesting balloon inflation via
> > > > virtio-balloon. The reason is that the virtio-balloon driver has
> > > > removed the page from its internal page list (via balloon_page_pop),
> > > > but balloon_page_enqueue_one also calls "list_del"  to do the removal.
> > > > This is necessary when it's used from balloon_page_enqueue_list, but
> > > > not from balloon_page_enqueue_one.
> > > > 
> > > > So remove the list_del balloon_page_enqueue_one, and update some
> > > > comments as a reminder.
> > > > 
> > > > Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> > > 
> > > 
> > > ok I posted v3 with typo fixes. 1/2 is this patch with comment changes. Pls take a look.
> > 
> > I really have no idea what you're talking about here :(.  Some other
> > discussion and patch thread, I suppose.
> > 
> > You're OK with this patch?
> 
> Not exactly. I will send v5 soon, you will be CC'd.

Just done. Do you see it?

> > Should this patch have cc:stable?
> 
> Yes. Sorry.

Actually no - 418a3ab1e778 is new since 5.2.

