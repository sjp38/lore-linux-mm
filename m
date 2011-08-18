Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 464BE900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 08:45:19 -0400 (EDT)
Received: by wyi11 with SMTP id 11so1861277wyi.14
        for <linux-mm@kvack.org>; Thu, 18 Aug 2011 05:45:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAG1a4rsO7JDqmYiwyxPrAHdLNbJt+wqymSzU9i1dv5w5C2OFog@mail.gmail.com>
References: <1312872786.70934.YahooMailNeo@web111712.mail.gq1.yahoo.com>
 <CAK1hOcN7q=F=UV=aCAsVOYO=Ex34X0tbwLHv9BkYkA=ik7G13w@mail.gmail.com>
 <1313075625.50520.YahooMailNeo@web111715.mail.gq1.yahoo.com>
 <201108111938.25836.vda.linux@googlemail.com> <CAG1a4rsO7JDqmYiwyxPrAHdLNbJt+wqymSzU9i1dv5w5C2OFog@mail.gmail.com>
From: Denys Vlasenko <vda.linux@googlemail.com>
Date: Thu, 18 Aug 2011 14:44:56 +0200
Message-ID: <CAK1hOcM5u-zB7fUnR5QVJGBrEnLMhK9Q+EmWBknThga70UQaLw@mail.gmail.com>
Subject: Re: running of out memory => kernel crash
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Ivanov <paivanof@gmail.com>
Cc: Mahmood Naderan <nt_mahmood@yahoo.com>, David Rientjes <rientjes@google.com>, Randy Dunlap <rdunlap@xenotime.net>, "\"linux-kernel@vger.kernel.org\"" <linux-kernel@vger.kernel.org>, "\"linux-mm@kvack.org\"" <linux-mm@kvack.org>

On Thu, Aug 18, 2011 at 4:18 AM, Pavel Ivanov <paivanof@gmail.com> wrote:
>>> Why "killing" does not appear here? Why it try to "find some
>>> recently used page"?
>>
>> Because killing is the last resort. As long as kernel can free
>> a page by dropping an unmodified file-backed page, it will do that.
>> When there is nothing more to drop, and still more free pages
>> are needed, _then_ kernel will start oom killing.
>
> I have a little concern about this explanation of yours. Suppose we
> have some amount of more or less actively executing processes in the
> system. Suppose they started to use lots of resident memory. Amount of
> memory they use is less than total available physical memory but when
> we add total size of code for those processes it would be several
> pages more than total size of physical memory. As I understood from
> your explanation in such situation one process will execute its time
> slice, kernel will switch to other one, find that its code was pushed
> out of RAM, read it from disk, execute its time slice, switch to next
> process, read its code from disk, execute and so on. So system will be
> virtually unusable because of constantly reading from disk just to
> execute next small piece of code. But oom will never be firing in such
> situation. Is my understanding correct?

Yes.

> Shouldn't it be considered as an unwanted behavior?

Yes. But all alternatives (such as killing some process) seem to be worse.

-- 
vda

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
