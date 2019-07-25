Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CB1DC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 05:12:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 374C12189F
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 05:12:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ExyQTREp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 374C12189F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1EAC8E002C; Thu, 25 Jul 2019 01:12:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCE258E001C; Thu, 25 Jul 2019 01:12:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B95FA8E002C; Thu, 25 Jul 2019 01:12:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 854F38E001C
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 01:12:09 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id j12so25525327pll.14
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 22:12:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KSVES4Di2vK/QdofzjdERnWb+kHxNc5zqBfVZ7xWzIg=;
        b=jCzXshun7nj/3jAk8awitSuc7wraneKH6BPTJAWLEvCKVRn6HS+ie06VcQVl1gj51i
         kq/XdIsed2z8rfPVK9Fpr+mjkzAbALhHGNHFpwsYNYOPUn9YiApqqiapsPgA1vOsHjcR
         ekLAA/rCKQVZdjVZqiLQQ+siIIBbtos5ybbdUSy10koUojCmRgRzfFYDMVs2O4DZZ132
         4qqDdC/VkFwmImVYTrZyB0Jd9HppS+Z5PD0jJoVhsUUsU5N+Q6VvRMbtbl5EYEXdwnL8
         pqpqE470plXQGrzfBm/+pPWecUkv+Jo9rs/tpT8mSqc1+m3QQvQVjIma89byG6Tkh/l9
         VBeQ==
X-Gm-Message-State: APjAAAX+QQH4PCe4xOMdkyUXP59Lirik8gJrLpY6s3wR1QL1Rnulzo7e
	IxDDCA/qFN1yaMRfK1DrwI9tcClemLDu774Q9dBLaa/dDQ9p8tHx4FjyEtu3MG1f9pRqZJ5DY6r
	uP80WOsgPGGMiDTJ+74/zlzCjCFmlmCAWIhT7t2Uz8NswSyGygCkdUk0gyfBSPGQ=
X-Received: by 2002:a63:3d8f:: with SMTP id k137mr85537868pga.337.1564031529098;
        Wed, 24 Jul 2019 22:12:09 -0700 (PDT)
X-Received: by 2002:a63:3d8f:: with SMTP id k137mr85537826pga.337.1564031528089;
        Wed, 24 Jul 2019 22:12:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564031528; cv=none;
        d=google.com; s=arc-20160816;
        b=A8i8ZTXQdyxz0pDwsApJCUz1YP0xgdJfuliqbNh0rjRAMOuW98E5bXk969ndEDJ0hf
         zM91Z6gCLruYiBl39wOkDMtaXIfAo2Qsp6wd2zrIe5c/2V2kefBarV2i65A+YuJnbuvL
         Lni7Ljt7syyWRfKWYcsg8nzyd+np/MIoWuOUCj35sIZa5cMq3dCtBLU8LLG3yQblauhP
         5FFKaZ5gZDaavig7wBBO8EP2mBVZIkrAK526tohEkz59dK73siodwk01PRzFBFdEs5FR
         ZdGlwfIcPJzTf7dEBdVMQgVMlEzymvLvyzMB24Y1jA4A8uvyf14KRYjuA7nzZlleXAtM
         G1Gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=KSVES4Di2vK/QdofzjdERnWb+kHxNc5zqBfVZ7xWzIg=;
        b=tRx1vTJX0zGIdhOKoVnvFv3qh4o5oS+y4KicK/ChJtL2rfERKoesr5drO+w4ZLJ2yL
         qVwSN0ozk02noGGQfqGeTt4Dk3fszBwrKPk/pRXYXsdqiK9vHq5wqw162WAe1n147BBw
         PKIBgLfAhYoR7w3cg2YkO6I2XfoiI9FtuLWIwyU2r6vlbxnOY97felNRtwloZMaYLq8T
         5TPI2pvot7jm711bLaotFmpCi69jvZ7to8sLcDcmn4/0v9bDsO8Bpcq1iNd2txhD2Qso
         CaUzP0xOnEnlRYgnkvOKxnDWYQDwU/oMNNDbRIX41Ypq+5Av3xvg6rCT/glCiDWs0vaK
         /PmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ExyQTREp;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ck8sor57957536pjb.22.2019.07.24.22.12.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 22:12:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ExyQTREp;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=KSVES4Di2vK/QdofzjdERnWb+kHxNc5zqBfVZ7xWzIg=;
        b=ExyQTREpJfPmp7vJJ2Y1yGisU8EG2uYGosxo5RZHBLokzfppj53F61F1dorQZkWp4L
         1u86lScc0D9LhTdytlPOQoxRM6tw17QDqBS2daquIH4r/ZiHEgkp5YC4rNfWJ7q0nEYZ
         jBQySMe9zOntgtD8mgrOdqsUitUnzzhex3OyfDVVQ4FDOazw5yPVqSQSFA6GVai0TVAg
         vS7ToBS9H80ao1cVZiEbreO1AypmHBqcHzVsDbI7WHPG5Tg+xrl6J5fStZkg4X02FJzr
         J9WrD4s8anQnCFv8ON43mpqzu5no7Lmk9m9UdgdG6IaKHG36YrWvYEo7GwbroRraM//A
         tLXQ==
X-Google-Smtp-Source: APXvYqxKwc0wBeIkkfcXVdrRwVawpYOlqn58OtEpJPbVKg5TevIqJAnENN5egvEYfpctwul3xCGz2Q==
X-Received: by 2002:a17:90a:b104:: with SMTP id z4mr90704862pjq.102.1564031527596;
        Wed, 24 Jul 2019 22:12:07 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id g2sm62427425pfb.95.2019.07.24.22.12.03
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 22:12:06 -0700 (PDT)
Date: Thu, 25 Jul 2019 14:12:00 +0900
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yu Zhao <yuzhao@google.com>, Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Mauro Carvalho Chehab <mchehab+samsung@kernel.org>,
	Matthew Wilcox <willy@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>, Peng Fan <peng.fan@nxp.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: replace list_move_tail() with
 add_page_to_lru_list_tail()
Message-ID: <20190725051200.GA65392@google.com>
References: <20190716212436.7137-1-yuzhao@google.com>
 <20190724193249.00875235c4fa2495e0098451@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724193249.00875235c4fa2495e0098451@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

On Wed, Jul 24, 2019 at 07:32:49PM -0700, Andrew Morton wrote:
> On Tue, 16 Jul 2019 15:24:36 -0600 Yu Zhao <yuzhao@google.com> wrote:
> 
> > This is a cleanup patch that replaces two historical uses of
> > list_move_tail() with relatively recent add_page_to_lru_list_tail().
> > 
> 
> Looks OK to me.
> 
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -515,7 +515,6 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
> >  	del_page_from_lru_list(page, lruvec, lru + active);
> >  	ClearPageActive(page);
> >  	ClearPageReferenced(page);
> > -	add_page_to_lru_list(page, lruvec, lru);
> >  
> >  	if (PageWriteback(page) || PageDirty(page)) {
> >  		/*
> > @@ -523,13 +522,14 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
> >  		 * It can make readahead confusing.  But race window
> >  		 * is _really_ small and  it's non-critical problem.
> >  		 */
> > +		add_page_to_lru_list(page, lruvec, lru);
> >  		SetPageReclaim(page);
> >  	} else {
> >  		/*
> >  		 * The page's writeback ends up during pagevec
> >  		 * We moves tha page into tail of inactive.
> >  		 */
> 
> That comment is really hard to follow.  Minchan, can you please explain
> the first sentence?

It meant "normal deactivation from the pagevec full". The sentence is
very odd to me, too. ;-( 
Let's remove the weird comment in this chance.

Thanks.

