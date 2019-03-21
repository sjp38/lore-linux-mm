Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD0AFC10F00
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 09:21:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E6A4218D4
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 09:21:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E6A4218D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA7856B0003; Thu, 21 Mar 2019 05:21:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C571A6B0006; Thu, 21 Mar 2019 05:21:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B46606B0007; Thu, 21 Mar 2019 05:21:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 949616B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 05:21:47 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id f89so5356736qtb.4
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 02:21:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AVT41CEyC25KmfkzIyCyWF8KIQqm++BNqyfkHFE/lJ8=;
        b=dl+1JbUOkHyX+3i0YrejBo5e52TG1tTe34CXZ0cuQBA3bnLOyjTVEvXmqLGsoHQaVd
         sgGAMsGD7C7gq7i8MmBku2yJfCMmKq0RiCc+WDBsgzYGCk1RJ4zRGW5OuziH51A2CwWe
         6a1W1uToGfhcrresndeqWSSmbqA/2ASap+llD04hg17C/PUID+3HwIJBqPTbjMjEaeGw
         gvrhpVVzYg3yiy2AM03Hxz7F4L9O4IV1f9U/PxA22ZvkoiB7XIkZ25oT3QiRlFZBSyzG
         10eOw3PqiRxj2aVUo1mLQOk/IjiMqscj46COU7+WPe0YaeusNypNZ6ANfwx/pKVfYJr6
         BRgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUSVTgbsyvymOhOC59LaHj9MeVchqJeF1Z5pM245mO9HPqrNPyb
	XSutSmoOnCkM9hcrPRhbSEi5Sg6qM24+iPZtAv2oc75BZf00d3I9bFjgXuehPihiGIVVRkF1Zuc
	I3C5U7M81r5FrkuGmClQuAzLMdrVrD6s32XAJNhm4SbM6mvM+KM2BC+RjJKSVbtK76g==
X-Received: by 2002:a37:e40f:: with SMTP id y15mr1808298qkf.230.1553160107325;
        Thu, 21 Mar 2019 02:21:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxHWYBgjVHpsyM1Uy9cQ6gsFOsZUu+hgc4Ifu9+9+E8lfAvCpK3cxj/eMbSx120dVbo9RLm
X-Received: by 2002:a37:e40f:: with SMTP id y15mr1808271qkf.230.1553160106666;
        Thu, 21 Mar 2019 02:21:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553160106; cv=none;
        d=google.com; s=arc-20160816;
        b=NBhoCF34XWOrciXBECcgkHVgBr60GJoJVUCOIMSA6tkO1ucuUzpwIVSsGGTPq8/yWf
         CTgTfUDzioMvjzGFFkpQ3Anc+4TfbM74iyT7KslCqCdmeX3JIJjusUNZttULiNdbgHww
         Ugs7EsQxhNu+2a27jTxiqEG96ahdb9yDPXjEvy9ItXkll3hwrrgGm66PlUVxsk0mmi5P
         PUn2hbTZG4ix22lrF65jlAkfa0vIE2hmE4LwjWTaJ0XjTWl7Wo3q9RajOaOU9Hr/vEox
         bmUwXHz+zjXLBclN4myYmz/YAPjpKr223iZUUGF6eDny64J1RFr3QKvVZe9vgl8DtRSg
         Z0nA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AVT41CEyC25KmfkzIyCyWF8KIQqm++BNqyfkHFE/lJ8=;
        b=KlIfGVByjqjmgSukJom2BBm5RsCWN9v2yU6rLCII8qGkSPq1bomM6N++MhVsRbAOzG
         pnKGJMgcXHaZ6nPFsYXWUE7E8IAtRQ8PNY7Be2E0dJ86FHnK69wqBJUYDMBu1WCr3hRn
         vt8frLU7IjUsu1Jhbyx7mwNwF7PgaR2xSIx5IxIEmjUmVn8xx4nxLPRyc5lxM4F2Id2r
         zEB+rqwIDbHF7FZqmmIjL+Be3cv6Tsqd9msougCvDD1mX/pY+qH5jnd3d1WLMiVXC0W+
         BR0bPFObpBagZDTQvmwoTN7zecXWtfvZssjGULcXtq0PaVAlhKLTrAge9hhF0z571wWV
         dArA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k127si46958qkd.128.2019.03.21.02.21.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 02:21:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AB603F74A8;
	Thu, 21 Mar 2019 09:21:45 +0000 (UTC)
Received: from localhost (ovpn-12-72.pek2.redhat.com [10.72.12.72])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id CD0F3600C1;
	Thu, 21 Mar 2019 09:21:42 +0000 (UTC)
Date: Thu, 21 Mar 2019 17:21:38 +0800
From: Baoquan He <bhe@redhat.com>
To: Matthew Wilcox <willy@infradead.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Oscar Salvador <osalvador@suse.de>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	pasha.tatashin@oracle.com, mhocko@suse.com, rppt@linux.vnet.ibm.com,
	richard.weiyang@gmail.com, linux-mm@kvack.org
Subject: Re: [PATCH 1/3] mm/sparse: Clean up the obsolete code comment
Message-ID: <20190321092138.GY18740@MiWiFi-R3L-srv>
References: <20190320073540.12866-1-bhe@redhat.com>
 <20190320111959.GV19508@bombadil.infradead.org>
 <20190320122011.stuoqugpjdt3d7cd@d104.suse.de>
 <20190320122243.GX19508@bombadil.infradead.org>
 <20190320123658.GF13626@rapoport-lnx>
 <20190320125843.GY19508@bombadil.infradead.org>
 <20190321064029.GW18740@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190321064029.GW18740@MiWiFi-R3L-srv>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 21 Mar 2019 09:21:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/21/19 at 02:40pm, Baoquan He wrote:
> Hi all,
> 
> On 03/20/19 at 05:58am, Matthew Wilcox wrote:
> > On Wed, Mar 20, 2019 at 02:36:58PM +0200, Mike Rapoport wrote:
> > > There are more than a thousand -EEXIST in the kernel, I really doubt all of
> > > them mean "File exists" ;-)
> > 
> > And yet that's what the user will see if it's ever printed with perror()
> > or similar.  We're pretty bad at choosing errnos; look how abused
> > ENOSPC is:
> 
> When I tried to change -EEXIST to -EBUSY, seems the returned value will
> return back over the whole path. And -EEXIST is checked explicitly
> several times during the path. 
> 
> acpi_memory_enable_device -> __add_pages .. -> __add_section -> sparse_add_one_section
> 
> Only look into hotplug path triggered by ACPI event, there are also
> device memory and ballon memory paths I haven't checked carefully
> because not familiar with them.
> 
> So from the checking, I tend to agree with Oscar and Mike. There have
> been so many places to use '-EEXIST' to indicate that stuffs checked have
> been existing. We can't deny it's inconsistent with term explanation
> text. While the defense is that -EEXIST is more precise to indicate a
> static instance has been present when we want to create it, but -EBUSY
> is a little blizarre. I would rather see -EBUSY is used on a device.
> When want to stop it or destroy it, need check if it's busy or not.
> 
> #define EBUSY           16      /* Device or resource busy */
> #define EEXIST          17      /* File exists */
> 
> Obviously saying resource busy or not, it violates semanics in any
> language. So many people use EEXIST instead, isn't it the obsolete

Surely when we require a lock which is protecting resource, we can also
return -EBUSY since someone is busy on this resource. For creating one
instance, just check if the instance exists already, no matter what the
code comment of the errno is saying, IMHO, it really should not be -EBUSY.

Thanks
Baoquan

