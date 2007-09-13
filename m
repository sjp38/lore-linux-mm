Received: by fk-out-0910.google.com with SMTP id 18so489958fkq
        for <linux-mm@kvack.org>; Thu, 13 Sep 2007 05:29:26 -0700 (PDT)
Message-ID: <46E92D27.8050706@gmail.com>
Date: Thu, 13 Sep 2007 14:29:27 +0200
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: 2.6.23-rc4-mm1: deadlock while mmaping video device
References: <46E9226F.9010700@gmail.com> <20070913044726.1aa48f45.akpm@linux-foundation.org>
In-Reply-To: <20070913044726.1aa48f45.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Linux kernel mailing list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton napsal(a):
> On Thu, 13 Sep 2007 13:43:43 +0200 Jiri Slaby <jirislaby@gmail.com> wrote:
> 
>> Hi,
>>
>> I have this circular lock dependency on 2.6.23-rc4-mm1 when opening
>> /dev/video0 and mmaping it. the v4l driver is stk11xx:
>> http://www.fi.muni.cz/~xslaby/sklad/panics/mm-deadlock.png
>>
>> Using slub on x86_64 if that matters.
>>
>> For now, I'm unable to set up a netconsole, so only the picture linked above
>> is the best I have.
>>
> 
> oop, I think you'll want this:

yes, thanks,
-- 
http://www.fi.muni.cz/~xslaby/            Jiri Slaby
faculty of informatics, masaryk university, brno, cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
