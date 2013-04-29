Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 65E636B008C
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 14:44:41 -0400 (EDT)
Received: by mail-ee0-f71.google.com with SMTP id c13so8098928eek.6
        for <linux-mm@kvack.org>; Mon, 29 Apr 2013 11:44:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130425132157.GA32353@quack.suse.cz>
References: <20130424153810.GA25958@quack.suse.cz> <CAL1RGDXqtLPmM0kRofFwTv+jzr2cBGoe9X7oQLO_yoHGErJnxg@mail.gmail.com>
 <20130425132157.GA32353@quack.suse.cz>
From: Roland Dreier <roland@kernel.org>
Date: Mon, 29 Apr 2013 11:44:19 -0700
Message-ID: <CAL1RGDWPujGT6HKDg74dFT=C64NyO7y1aYjM1LH9YHZcWbf7qA@mail.gmail.com>
Subject: Re: Infiniband use of get_user_pages()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, linux-mm@kvack.org

On Thu, Apr 25, 2013 at 6:21 AM, Jan Kara <jack@suse.cz> wrote:
>> get_user_pages() actually goes to some trouble to return all small pages,
>> even when it has to split a single huge page into many entries in the
>> page array.  (Which is actually a bit unfortunate for our use here)

>   Does it? As far as I'm checking get_user_pages() and the fault path I
> don't see where it would be happening...

I'm talking about where __get_user_pages() calls follow_hugetlb_page()
and loops to fill in many entries in the page array from one huge
page.

 - R.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
