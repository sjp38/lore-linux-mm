Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id mAM2IT29016729
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 18:18:29 -0800
Received: from rv-out-0708.google.com (rvfc5.prod.google.com [10.140.180.5])
	by wpaz37.hot.corp.google.com with ESMTP id mAM2IRYF030797
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 18:18:28 -0800
Received: by rv-out-0708.google.com with SMTP id c5so1194957rvf.56
        for <linux-mm@kvack.org>; Fri, 21 Nov 2008 18:18:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.0811211618160.20523@chino.kir.corp.google.com>
References: <604427e00811211605j20fd00bby1bac86b4cc3c380b@mail.gmail.com>
	 <alpine.DEB.2.00.0811211618160.20523@chino.kir.corp.google.com>
Date: Fri, 21 Nov 2008 18:18:27 -0800
Message-ID: <6599ad830811211818g5ade68cua396713be94f80dc@mail.gmail.com>
Subject: Re: [PATCH][V2] Make get_user_pages interruptible
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Ying Han <yinghan@google.com>, linux-mm@kvack.org, akpm <akpm@linux-foundation.org>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 21, 2008 at 4:21 PM, David Rientjes <rientjes@google.com> wrote:
> Signed-off-by: Paul Menage <menage@google.com>
> Signed-off-by: Ying Han <yinghan@google.com>
>
> and the first signed-off line is usually indicative of who wrote the
> original change.  If Paul wrote this code, please add:
>
> From: Paul Menage <menage@google.com>

No, I didn't exactly write it originally - the only thing I added in
our kernel was the use of sigkill_pending() rather than checking for
TIF_MEMDIE.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
