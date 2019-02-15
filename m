Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01C77C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 15:26:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B38B2192D
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 15:26:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="KSNOoqqs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B38B2192D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5F068E0002; Fri, 15 Feb 2019 10:26:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A33F18E0001; Fri, 15 Feb 2019 10:26:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94A688E0002; Fri, 15 Feb 2019 10:26:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6A5528E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 10:26:51 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id a65so8367710qkf.19
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 07:26:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=eQQ5G47ht1L2LtaSIQ/9ji/Y/+sfRIjwdzgr3C6Kr9M=;
        b=rUG7wfRl29iYhIEJLG1QmPH8zwJjEGiW1jzZ+Cc9nFIbiF28Vk47uvGfRrZNBAyoLL
         cBQAVOxlpKFAoeNyxn0imlQoN0BVCLcWraqXWqBce3+eBDuBjcIFVSUDdT45N/BE+BEz
         SpN4tKx1V47Nr0nr3GDinsf4MCBby+FremvW1JyXXLwbzwDcoQYqrn+ZMRoz044ZkiUv
         277ZQxFKs0WfKsFPlFCbBCIX9V53QlYwm1dOavPbQPyIUzkvbllypZq3uxy1YhdK3fh6
         2ao7u2mvR3/t2qLRbyGdOoo9cqCoKl8Ul/dAyxttnw0gErKlBTnNPHgkMgv8ks3kmBE+
         RurA==
X-Gm-Message-State: AHQUAuY3TDr6e5F5tLLhntbzKKJ5CQu9btB1Ab+fRnDLMVd071FnfJpL
	fED0SaXUFPgYPc0zTiWVk4VVhWv5drrXkc7hJqo74K7Gqzz8qU+tzsN/+SQSPDJnjNccc2KjpZV
	lnLCb+TXQJyLiBiu8mEZc7fa3GsFqJnIaD6b/XmhrGOR81lXaeXid7Vz0/DcXZ50=
X-Received: by 2002:a37:c04a:: with SMTP id o71mr7294420qki.234.1550244411166;
        Fri, 15 Feb 2019 07:26:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia/0YovtN9Evsn5MgyQb0/EuNIQqAAzEFFvgL1j10LrE665h8k03fS53Iv37wU9Vt+D6JkM
X-Received: by 2002:a37:c04a:: with SMTP id o71mr7294387qki.234.1550244410494;
        Fri, 15 Feb 2019 07:26:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550244410; cv=none;
        d=google.com; s=arc-20160816;
        b=a5xRgG02VAoMApZmILqEVZXJe9ErCIHIh2kx++luOm0sAbxjCU+1h7R5O6YPIymwd1
         fa8ub7JU3Yeigqqe+ytzz4ONvbPOr2Tn+ud2eRxZC51Olo4rokeGDS2qYFOw0BvZB/WP
         uVnSNJamIhGRCsZ8MWYOUUyPwEkyA7ZS+ahAW4lUoIs7Y4MGwoNUOY9uVhGhc11lRXHM
         hUrAWN7wioAUFtkIboAyz6qY/aSkmWub4CpOrzD43qDT6+5lN32i7IA7bPdAQwqANYXl
         zqSW5UJC/GINMW2GObhp6Qf1gCIjsbwK37uGxN3FVaf293kcFsvGUwVq98lbliY6SMKV
         wcBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=eQQ5G47ht1L2LtaSIQ/9ji/Y/+sfRIjwdzgr3C6Kr9M=;
        b=QIC+kdLpt3UqOsZl4DWm8mGBP9ldCeilvEsoucqxxZCX6z8mQ+7ZF2YikTPmtfvRZj
         KRbFvgt9G+wwMYlhd26wqMAEz95MTea1Pdliu5ItQwJ7mHLgPkdoPLWrLBT0lwl3TMTv
         J9Zvlr/KBxn5Gg229efZV17Y1LWZVa6y83l1WH8VlM34fyt7GOwsO8AGCOIv04jVLIGF
         a1GZM+f8cvLzpu7S99Ix+yPpyRbNJ/G8QNVsP5U1DAd4YASH7tWpNR8vmCvJA+wDqH+s
         xT4oqXil9KVau6U9/KLZpOaaubS8Jb67FE4EcO+BfYGdxdrAOX8E5Lg0QTEZbSzV6geR
         uADw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=KSNOoqqs;
       spf=pass (google.com: domain of 01000168f1c4718d-91714478-72d3-47cd-ae36-2d781947ebde-000000@amazonses.com designates 54.240.9.31 as permitted sender) smtp.mailfrom=01000168f1c4718d-91714478-72d3-47cd-ae36-2d781947ebde-000000@amazonses.com
Received: from a9-31.smtp-out.amazonses.com (a9-31.smtp-out.amazonses.com. [54.240.9.31])
        by mx.google.com with ESMTPS id q128si657526qka.151.2019.02.15.07.26.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 15 Feb 2019 07:26:50 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168f1c4718d-91714478-72d3-47cd-ae36-2d781947ebde-000000@amazonses.com designates 54.240.9.31 as permitted sender) client-ip=54.240.9.31;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=KSNOoqqs;
       spf=pass (google.com: domain of 01000168f1c4718d-91714478-72d3-47cd-ae36-2d781947ebde-000000@amazonses.com designates 54.240.9.31 as permitted sender) smtp.mailfrom=01000168f1c4718d-91714478-72d3-47cd-ae36-2d781947ebde-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1550244409;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=ph+Ox1e7xNScZGS+VdWAQM0Ff/E6RjNkQYhIunoJh5I=;
	b=KSNOoqqsLE+r8KYX2OGbVKpGlhsa+Ylr4yLduMXvPZjEz1KtCJCrXjbXi05MCABz
	GfKhX70kQFfDTpoB3XA0etFSJKc3qzbKiYMlp8/e0SZ/sM66h8/4m0+1mqYIrp4Ss5v
	X7EU6bVAeo2r2h9wXORmJ3AkbZYhtBwR8GhooEac=
Date: Fri, 15 Feb 2019 15:26:49 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Jason Gunthorpe <jgg@ziepe.ca>
cc: Ira Weiny <ira.weiny@intel.com>, 
    Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org, 
    dave@stgolabs.net, jack@suse.cz, linux-mm@kvack.org, kvm@vger.kernel.org, 
    kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, 
    linux-fpga@vger.kernel.org, linux-kernel@vger.kernel.org, 
    alex.williamson@redhat.com, paulus@ozlabs.org, benh@kernel.crashing.org, 
    mpe@ellerman.id.au, hao.wu@intel.com, atull@kernel.org, mdf@kernel.org, 
    aik@ozlabs.ru
Subject: Re: [PATCH 0/5] use pinned_vm instead of locked_vm to account pinned
 pages
In-Reply-To: <20190214221629.GD1739@ziepe.ca>
Message-ID: <01000168f1c4718d-91714478-72d3-47cd-ae36-2d781947ebde-000000@email.amazonses.com>
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com> <20190211225447.GN24692@ziepe.ca> <20190214015314.GB1151@iweiny-DESK2.sc.intel.com> <20190214060006.GE24692@ziepe.ca> <20190214193352.GA7512@iweiny-DESK2.sc.intel.com> <20190214201231.GC1739@ziepe.ca>
 <20190214214650.GB7512@iweiny-DESK2.sc.intel.com> <20190214221629.GD1739@ziepe.ca>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.15-54.240.9.31
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2019, Jason Gunthorpe wrote:

> On Thu, Feb 14, 2019 at 01:46:51PM -0800, Ira Weiny wrote:
>
> > > > > Really unclear how to fix this. The pinned/locked split with two
> > > > > buckets may be the right way.
> > > >
> > > > Are you suggesting that we have 2 user limits?
> > >
> > > This is what RDMA has done since CL's patch.
> >
> > I don't understand?  What is the other _user_ limit (other than
> > RLIMIT_MEMLOCK)?
>
> With todays implementation RLIMIT_MEMLOCK covers two user limits,
> total number of pinned pages and total number of mlocked pages. The
> two are different buckets and not summed.

Applications were failing at some point because they were effectively
summed up. If you mlocked/pinned a dataset of more than half the memory of
a system then things would get really weird.

Also there is the possibility of even more duplication because pages can
be pinned by multiple kernel subsystems. So you could get more than
doubling of the number.

The sane thing was to account them separately so that mlocking and
pinning worked without apps failing and then wait for another genius
to find out how to improve the situation by getting the pinned page mess
under control.

It is not even advisable to check pinned pages against any limit because
pages can be pinned by multiple subsystems.

The main problem here is that we only have a refcount to indicate pinning
and no way to clearly distinguish long term from short pins. In order to
really fix this issue we would need to have a list of subsystems that have
taken long term pins on a page. But doing so would waste a lot of memory
and cause a significant performance regression.

And the discussions here seem to be meandering around these issues.
Nothing really that convinces me that we have a clean solution at hand.

