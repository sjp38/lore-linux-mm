Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id EB4E76B0055
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 15:39:32 -0400 (EDT)
Subject: Re: [RFC] set the thread name
From: Stefani Seibold <stefani@seibold.net>
In-Reply-To: <36ca99e90906161214u6624014q3f3dc4e234bdf772@mail.gmail.com>
References: <1245177592.14543.1.camel@wall-e>
	 <36ca99e90906161214u6624014q3f3dc4e234bdf772@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 16 Jun 2009 21:40:27 +0200
Message-Id: <1245181227.16466.3.camel@wall-e>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bert Wesarg <bert.wesarg@googlemail.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Am Dienstag, den 16.06.2009, 21:14 +0200 schrieb Bert Wesarg:
> Hi,
> 
> On Tue, Jun 16, 2009 at 20:39, Stefani Seibold<stefani@seibold.net> wrote:
> > Currently it is not easy to identify a thread in linux, because there is
> > no thread name like in some other OS.
> >
> > If there were are thread name then we could extend a kernel segv message
> > and the /proc/<pid>/task/<tid>/... entries by a TName value like this:
> prctl(PR_SET_NAME, ...) works perfectly here.
> 
Ooops... I did not noticed that this is already implemented. Thats works
perfectly ;-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
