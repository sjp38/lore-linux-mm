Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1B5E96B0082
	for <linux-mm@kvack.org>; Sat, 14 Mar 2015 13:24:17 -0400 (EDT)
Received: by ladw1 with SMTP id w1so11546845lad.0
        for <linux-mm@kvack.org>; Sat, 14 Mar 2015 10:24:16 -0700 (PDT)
Received: from shrek.krogh.cc (188-178-198-210-static.dk.customer.tdc.net. [188.178.198.210])
        by mx.google.com with ESMTPS id j17si3915800lbh.5.2015.03.14.10.24.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Mar 2015 10:24:15 -0700 (PDT)
Message-ID: <a0dcd8d7307e313474d4d721c76bb5a9.squirrel@shrek.krogh.cc>
In-Reply-To: 
 <CABYiri81_RAtJizfpOdNPc6m9_Q2u0O35NX0ZhO1cxFpm866HQ@mail.gmail.com>
References: <52ec58f434865829c37337624d124981.squirrel@shrek.krogh.cc>
    <CABYiri81_RAtJizfpOdNPc6m9_Q2u0O35NX0ZhO1cxFpm866HQ@mail.gmail.com>
Date: Sat, 14 Mar 2015 18:25:19 +0100
Subject: Re: High system load and 3TB of memory.
From: jesper@krogh.cc
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Korolyov <andrey@xdel.ru>
Cc: jesper@krogh.cc, linux-mm@kvack.org

> On Sat, Mar 14, 2015 at 8:05 PM,  <jesper@krogh.cc> wrote:
>> Hi
>> I have a 3.13 (ubuntu LTS) server with 3TB of memory and under certain
>> load
>> conditions it can spiral off to 80+% system load. Per recommendation on
>> IRC
>> yesterday I have captured 2 perf reports (I'm new to perf, so I'm not
>> sure they tell precisely whats needed.
>>
>> Bad situation (high sysload 80%+)


> Hi Jesper, please take a look on
> http://marc.info/?l=linux-mm&m=141605213522925&w=2, there is a long
> and unfinished discussion as it seems very problematic to make a
> deterministic reproduction of the bug in our environments. If you can
> observe same lockups with more ease, it`ll help a lot in the issue
> pinning and fixing.


Hi Andrey.

Yes it looks indeed familiar. I can do a fair amount of testing and our
normal production load triggers the problem 6-10 times per day and I'm
willing to garther data to help move forward. What do you suggest is next?

Jesper


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
