Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9079FC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 23:52:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EEB6222AA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 23:52:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EEB6222AA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D5B3B8E0002; Wed, 13 Feb 2019 18:52:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D324F8E0001; Wed, 13 Feb 2019 18:52:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C20188E0002; Wed, 13 Feb 2019 18:52:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7FE138E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 18:52:14 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id w16so3225269pfn.3
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 15:52:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dZBoS2pYoJhWE59lb7LjEUlWsjeb4VDx//7NxMjTkyM=;
        b=BIVkyOD6/EaGSLC7GEgyf+PIJSvdSYlPw4wtg/uyPVVQPeapVlbQO57EH3rQdnCTzA
         ofqaDwuQrK265YJzIGuMJ+EHovDtsbDot2xH4L9d5isiX/JcuUUS1Zi2MPkWCuk+rkEJ
         O5faLbeiB2BjZRtaCY8RojOWKaIil9H60UhM5VSJjUl2ZxZuqW7iQORmzy7awV9FkmH2
         mvi5Yx7N+2KnHXatlqlkygKVP0+3VroFlVOZpisVenFP61C/UZ/IXBzABjFpwVk83A8G
         xNCgHygFdVLEDsocUD01Qn0IjKYmftGu57N+SXqm+QHYkZLg/K37Tge2vX9k8tzp+69N
         3cjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaBH+g6FsB1Sdx/N3Cm5ErCfNtU4wFazn1J8CwuW6jt6Eao9bYR
	b/q40fb05m8EilOKjJoAWeX4AL46snxF5ToHl0DP718QVAW02/8J91VV89cPEipF8cLum34O5P0
	O56IVn0M5AOdo/1/jKVqfaxzfH4nlxqRI+7eaRQXn934aVs2MlxsDNEawTXoJtqov3g==
X-Received: by 2002:a63:515d:: with SMTP id r29mr785579pgl.350.1550101934023;
        Wed, 13 Feb 2019 15:52:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZJgrkGKYeNSOojWnaeGBVgMwFg6IxzSzk+4/9qmv4ZiVZqkeecgf3VfhV78uXdKj9b9HQK
X-Received: by 2002:a63:515d:: with SMTP id r29mr785530pgl.350.1550101933205;
        Wed, 13 Feb 2019 15:52:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550101933; cv=none;
        d=google.com; s=arc-20160816;
        b=FKTefZiDOFxvHkmm9LLkxPSzEn5jhJzIYvFpyZCyi8h7rVAGBXoqkyzNT719Xc14hv
         nmymY8KoVgh9u1rYcc64vK0k2g34D1bVnRor9cliVhojWJKDK53L/GRb5uJ4dmQQl9Yw
         XHc7Mut9aM6HXIcJwrw5JHI67niogmZcfPVFLust5h8xOnWykNlSqqGSeE2AC8/zcGgI
         x4u6R+xI5b8uma5vqJ0A0NRVe+AUGdnI7VbIKiL8NwfPL9aHiMPu8vOdAkf7A7SshhnD
         rWIZTuFGOsYlgTQgT9eVB36OGLw8DR/B2Tfv1Hg8UmKv8xaDoWGEJHrCp4LoK57YsdMJ
         yNgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dZBoS2pYoJhWE59lb7LjEUlWsjeb4VDx//7NxMjTkyM=;
        b=k06NNOtR93XZ5yKVS4rNnoNuGBtZ500a9a+9A+oJ++aHJe3wCdJM2CWsd4cPj5TRNV
         YE7b6HUOvER6F3gRMbMj+56044fHhcszbdHGWmEOzN40mVIfUESRDcSjJ+ZzSnUcgcqf
         OHR6T4jAyzTCwCHjRJYc1dFZXm8qb8aLBrEHBzkhknw2/S3dXGJX9VVm93azUweqEhg0
         JJ/XxyKBYWN9LYr2uqLM/RG3ZfJhoq49HQKaeHE99wabl2YXi+b3miwYpsCI+++IKjOU
         FV2BdFzjHsah1DSAX4LjNhx7UNg9OK58l8V1CybmVeCN7mwTvJT+zC3S5GYCM8GxSvMr
         Zo0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id j1si650090pgp.449.2019.02.13.15.52.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 15:52:13 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Feb 2019 15:52:12 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,367,1544515200"; 
   d="scan'208";a="134118611"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 13 Feb 2019 15:52:08 -0800
Date: Wed, 13 Feb 2019 15:52:01 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-mips@vger.kernel.org, linux-kernel@vger.kernel.org,
	kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org, kvm@vger.kernel.org,
	linux-fpga@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org,
	linux-scsi@vger.kernel.org, devel@driverdev.osuosl.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-fbdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	devel@lists.orangefs.org, linux-mm@kvack.org,
	ceph-devel@vger.kernel.org, rds-devel@oss.oracle.com,
	John Hubbard <jhubbard@nvidia.com>,
	David Hildenbrand <david@redhat.com>,
	Cornelia Huck <cohuck@redhat.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Joerg Roedel <joro@8bytes.org>, Wu Hao <hao.wu@intel.com>,
	Alan Tull <atull@kernel.org>, Moritz Fischer <mdf@kernel.org>,
	David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Christian Benvenuti <benve@cisco.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Matt Porter <mporter@kernel.crashing.org>,
	Alexandre Bounine <alex.bou9@gmail.com>,
	Kai =?iso-8859-1?Q?M=E4kisara?= <Kai.Makisara@kolumbus.fi>,
	"James E.J. Bottomley" <jejb@linux.ibm.com>,
	"Martin K. Petersen" <martin.petersen@oracle.com>,
	Rob Springer <rspringer@google.com>,
	Todd Poynor <toddpoynor@google.com>,
	Ben Chan <benchan@chromium.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Stefano Stabellini <sstabellini@kernel.org>,
	Martin Brandenburg <martin@omnibond.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH V2 3/7] mm/gup: Change GUP fast to use flags rather than
 a write 'bool'
Message-ID: <20190213235200.GA1151@iweiny-DESK2.sc.intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190213230455.5605-1-ira.weiny@intel.com>
 <20190213230455.5605-4-ira.weiny@intel.com>
 <20190213231110.GD24692@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213231110.GD24692@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 04:11:10PM -0700, Jason Gunthorpe wrote:
> On Wed, Feb 13, 2019 at 03:04:51PM -0800, ira.weiny@intel.com wrote:
> > From: Ira Weiny <ira.weiny@intel.com>
> > 
> > To facilitate additional options to get_user_pages_fast() change the
> > singular write parameter to be gup_flags.
> 
> So now we have:
> 
> long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
> 		    struct page **pages, unsigned int gup_flags);
> 
> and 
> 
> int get_user_pages_fast(unsigned long start, int nr_pages,
> 			unsigned int gup_flags, struct page **pages)
> 
> Does this make any sense? At least the arguments should be in the same
> order, I think.

Yes...  and no.  see below.

> 
> Also this comment:
> /*
>  * get_user_pages_unlocked() is suitable to replace the form:
>  *
>  *      down_read(&mm->mmap_sem);
>  *      get_user_pages(tsk, mm, ..., pages, NULL);
>  *      up_read(&mm->mmap_sem);
>  *
>  *  with:
>  *
>  *      get_user_pages_unlocked(tsk, mm, ..., pages);
>  *
>  * It is functionally equivalent to get_user_pages_fast so
>  * get_user_pages_fast should be used instead if specific gup_flags
>  * (e.g. FOLL_FORCE) are not required.
>  */
> 
> Needs some attention as the recommendation is now nonsense.

IMO they are not functionally equivalent.

We can't remove *_unlocked() as it is used as both a helper for the arch
specific *_fast() calls, _and_ in drivers.  Again I don't know the history here
but it could be that the drivers should never have used the call in the first
place???  Or been converted at some point?

I could change the comment to be something like

/*
 * get_user_pages_unlocked() is only to be used by arch specific
 * get_user_pages_fast() calls.  Drivers should be calling
 * get_user_pages_fast()
 */

Instead of the current comment.

And change the drivers to get_user_pages_fast().

However, I'm not sure if these drivers need the FOLL_TOUCH flag which
*_unlocked() adds for them.  And adding FOLL_TOUCH to *_fast() is not going to
give the same functionality.

It _looks_ like we can add FOLL_TOUCH functionality to the fast path in the
generic code.  I'm not sure about the arch's.

If we did that then we can have those drivers use FOLL_TOUCH or not in *_fast()
if they want/need.

> 
> Honestly a proper explanation of why two functions exist would be
> great at this point :)

I've not researched it.  I do agree that there seems to be a lot of calls in
this file and the differences are subtle.

Ira

> 
> Jason

