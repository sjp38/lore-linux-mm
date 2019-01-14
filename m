Return-Path: <SRS0=uJng=PW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96BC2C43387
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 09:14:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51E8E20660
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 09:14:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MwN3PaR8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51E8E20660
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB6098E0003; Mon, 14 Jan 2019 04:14:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3D598E0002; Mon, 14 Jan 2019 04:14:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2D338E0003; Mon, 14 Jan 2019 04:14:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 93C6E8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 04:14:01 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id q16so19492214ios.1
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 01:14:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=pIxlYDDgPHqQ9CK9up+5xb8otdBsHFZQrcLiqj227qI=;
        b=UU+4d5NGGiwghG9HeteenXzHx8OU3Nx8wg+3ONVcL8PiokRS4pJgD0F7804BPGncwy
         72T22CScoQVzsCRC9zE2SKjZGol4hGnanUflbtRw8V4IYNn4RWTywUTQGw6NGQ+f0q7g
         AI9Sahhm2BIAacIt3zglP7njJN+vNkADWieEfj6hhcBZaGByhA7MWI6aYNJDEKImBgyY
         tqoyLzdea2RuZk5n3eY7TKMePPy4m1Hb5LFpQhVxvSxUXgCWlwH0XL9WSbyPBDYXlwxX
         KYlEKqeFlQMue1ZLze4E9JCRMfMaz9nAti4amCmNnaAdbfhAKbG7wjffYOdDBL9nUKrn
         TjYg==
X-Gm-Message-State: AJcUukeEopzXAtjEbSpxtuN9NXStFoixPyW9GYZI6wNZwpMwFKNtDZd2
	bFcp4EEE/SCv8DRQyD43LhlXsS/kk3iENCYoFyz1E+qCSHhU0KkGb8fb351IBncAgclPxumMnOc
	mIHnwyOs7NEMv0YOT8BCFvrJJ+S/f4VVc3upV6s6x/K4SKGAt+/OEfWE2bHoUhi9EJe25pe+dS2
	r9KldXlsBYHV8T/PtgGVwrg6SJkO4r0Ij5+MdnCMVeoRdXpPQdSkVZLhY4cqnDxY9NKvWfJCw1F
	ln4eRCZs+EkTU26uOFrK9okpQ64pvT7UXpYYzarogjVq0YuqGSyYFFNhuxpIj/mjpgx5ya76O4K
	HsOsgPuVf7Gn5//VvOHfGYjW6uZjg/fSFQUPIGV1KGXMIICd+Heqx5dyuD7oBExSkEZFKeu3oOr
	U
X-Received: by 2002:a05:660c:4c5:: with SMTP id v5mr7864558itk.104.1547457241338;
        Mon, 14 Jan 2019 01:14:01 -0800 (PST)
X-Received: by 2002:a05:660c:4c5:: with SMTP id v5mr7864533itk.104.1547457240437;
        Mon, 14 Jan 2019 01:14:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547457240; cv=none;
        d=google.com; s=arc-20160816;
        b=rgTkBohG3qmRrcjLKm3xR4MePidmFO3Q8hPKK2fDGPoiCb/LJ3/m9BsvabCxDRbGYt
         vrCLimoRClLvz9f8nqj9W6hI7g0mkghxk5nIHYKTj9kICOxnvfaa6fnM03fhSDW7ZiFV
         r+3IwmM7vV9bFWNjrxqNp3bKzw53Mt/lf3/a0T8Rxgo9vhZhub5KFpHf4PleMufdvMdN
         dW0qXy1AjXjzSs+1F//XSIWDgCQ2r3MT+LbCcC104ItsYQ66a2Dii3NXCNva58cbM+ZH
         q0s3xD7Vddy/zZxPzmzDTazzSQO3ZeRqpeQF8/I7RHuSeX56SlGdo4Xtmf4tp7L5wFS9
         Yy9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=pIxlYDDgPHqQ9CK9up+5xb8otdBsHFZQrcLiqj227qI=;
        b=0Oigz385FcD+CsiotPK/OujMI5T6kzfm4YQ4X3kVmOnEWnT9pitRbPdp7sJGNIyDkT
         76CexoCYaM7679H5OWM/2VCol3s8Niwn6vnjxZCB2Rf1OfKBu6zce/GISMXUnKQR4Sxa
         9dRWxsYLryTwPLYkbS+aBm323GYIdpH/wEAbMes2KKQooo6ArcqpWTWuBBTlVRTkmIze
         h3pbTEb4hsM09N0RYfnsr6bqxPUlU0VGJP7nscYECmOSXebdFcvSfdGP1t9BS8VfyCgd
         dncWmdzoqMe63yOXuKG+86S/Bs5qtZ9pSINphOfGXWr6RWx0wOb7Q1bnoVsZgC/f2Azw
         UIXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=MwN3PaR8;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x64sor47271743iof.102.2019.01.14.01.14.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 01:14:00 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=MwN3PaR8;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=pIxlYDDgPHqQ9CK9up+5xb8otdBsHFZQrcLiqj227qI=;
        b=MwN3PaR8w30I5kdZvUms5ZTH3nwICZq9dTAN4QjnKrcqsCkNJLnDKbNjS8MsmPGBlr
         fgEOK+TxlotTOZ9inRI1NPpRxl1l3crjyFrCy2my731zsyJDvGGbmh4hFPRpHDnRC/bD
         dJpwonPJCy0Q10vAMOwfU+H5JdqqqjyR399pkR9ou5+kD0l9CDnmsDbb17ldt0WmteV3
         FzCCM9kxKBavP7qHHBQQ///e/gIXcKLw8t9eVRv6BU8jrhdXprIMz+x4GjkVMYH+GOL8
         gQuYR1NmR3hSoCN9HX20xuXu3ROaPLlHn3sYcVd4+4d4qTDeZF3gCFDcrQCIlGIsV8u/
         aebA==
X-Google-Smtp-Source: ALg8bN4Y4wLB7NmE9fU3NzatGqFg3PqsV2WiWgzvw22LG+vbKmq8sNOClWoHbRl8jCvp8sUF7FehuWDdsVfejKw45Dg=
X-Received: by 2002:a5e:de01:: with SMTP id e1mr15764932iok.137.1547457239825;
 Mon, 14 Jan 2019 01:13:59 -0800 (PST)
MIME-Version: 1.0
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
 <1547183577-20309-4-git-send-email-kernelfans@gmail.com> <20190114075113.GB1973@rapoport-lnx>
 <CAFgQCTtN4CGFz5xf+uci1ow032oQMB5pExHG01EtgrOpqXrJKA@mail.gmail.com> <20190114085037.GC1973@rapoport-lnx>
In-Reply-To: <20190114085037.GC1973@rapoport-lnx>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 14 Jan 2019 17:13:48 +0800
Message-ID:
 <CAFgQCTtKO445m9rq+cxuX2PqBW4uTNh=62ETFt7zVQGCZ4RaXA@mail.gmail.com>
Subject: Re: [PATCHv2 3/7] mm/memblock: introduce allocation boundary for
 tracing purpose
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, 
	Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, 
	Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Chao Fan <fanc.fnst@cn.fujitsu.com>, 
	Baoquan He <bhe@redhat.com>, Juergen Gross <jgross@suse.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, x86@kernel.org, 
	linux-acpi@vger.kernel.org, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190114091348.DYM48NrQf1gDlZhY6gGyFmZ0FNlAsXqich2bIUy3atY@z>

On Mon, Jan 14, 2019 at 4:50 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> On Mon, Jan 14, 2019 at 04:33:50PM +0800, Pingfan Liu wrote:
> > On Mon, Jan 14, 2019 at 3:51 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> > >
> > > Hi Pingfan,
> > >
> > > On Fri, Jan 11, 2019 at 01:12:53PM +0800, Pingfan Liu wrote:
> > > > During boot time, there is requirement to tell whether a series of func
> > > > call will consume memory or not. For some reason, a temporary memory
> > > > resource can be loan to those func through memblock allocator, but at a
> > > > check point, all of the loan memory should be turned back.
> > > > A typical using style:
> > > >  -1. find a usable range by memblock_find_in_range(), said, [A,B]
> > > >  -2. before calling a series of func, memblock_set_current_limit(A,B,true)
> > > >  -3. call funcs
> > > >  -4. memblock_find_in_range(A,B,B-A,1), if failed, then some memory is not
> > > >      turned back.
> > > >  -5. reset the original limit
> > > >
> > > > E.g. in the case of hotmovable memory, some acpi routines should be called,
> > > > and they are not allowed to own some movable memory. Although at present
> > > > these functions do not consume memory, but later, if changed without
> > > > awareness, they may do. With the above method, the allocation can be
> > > > detected, and pr_warn() to ask people to resolve it.
> > >
> > > To ensure there were that a sequence of function calls didn't create new
> > > memblock allocations you can simply check the number of the reserved
> > > regions before and after that sequence.
> > >
> > Yes, thank you point out it.
> >
> > > Still, I'm not sure it would be practical to try tracking what code that's called
> > > from x86::setup_arch() did memory allocation.
> > > Probably a better approach is to verify no memory ended up in the movable
> > > areas after their extents are known.
> > >
> > It is a probability problem whether allocated memory sit on hotmovable
> > memory or not. And if warning based on the verification, then it is
> > also a probability problem and maybe we will miss it.
>
> I'm not sure I'm following you here.
>
> After the hotmovable memory configuration is detected it is possible to
> traverse reserved memblock areas and warn if some of them reside in the
> hotmovable memory.
>
Oh, sorry that I did not explain it accurately. Let use say a machine
with nodeA/B/C from low to high memory address. With top-down
allocation by default, at this point, memory will always be allocated
from nodeC. But it depends on machine whether nodeC is hotmovable or
not. The verification can pass on a machine with unmovable nodeC , but
fails on a machine with movable nodeC. It will be a probability issue.

Thanks

[...]

