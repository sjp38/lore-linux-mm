Received: by rv-out-0708.google.com with SMTP id f25so2257767rvb.26
        for <linux-mm@kvack.org>; Tue, 20 May 2008 07:56:48 -0700 (PDT)
Message-ID: <cfd18e0f0805200756t1e7e33d7rd3ea5b2ecc1e87dc@mail.gmail.com>
Date: Tue, 20 May 2008 16:56:48 +0200
From: "Michael Kerrisk" <mtk.manpages@googlemail.com>
Subject: Re: [PATCH 1/8] Scaling msgmni to the amount of lowmem
In-Reply-To: <4832E423.5040708@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <cfd18e0f0805200728j1f38d90s1f6355b71e2d76@mail.gmail.com>
	 <4832E423.5040708@bull.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nadia Derbey <Nadia.Derbey@bull.net>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Fixing the bad list address in my initial mail: CC += linux-mm@kvack.org]

On Tue, May 20, 2008 at 4:45 PM, Nadia Derbey <Nadia.Derbey@bull.net> wrote:
> Michael Kerrisk wrote:
>>
>> Hello Nadia,
>>
>> Regarding your:
>>
>> [PATCH 1/8] Scaling msgmni to the amount of lowmem
>> http://article.gmane.org/gmane.linux.kernel/637849/
>> which I see has made its way in 2.6.26-rc
>>
>> Your patch has the following change:
>>
>> -#define MSGPOOL (MSGMNI*MSGMNB/1024)  /* size in kilobytes of message
>> pool */
>> +#define MSGPOOL (MSGMNI * MSGMNB) /* size in bytes of message pool */
>>
>> Since this constitutes a kernel-userland interface change, so please
>> do CC me, so that I can change the man pages if needed.
>
> Oops, sorry for not doing it: I misunderstood the "unused"
>
>>
>> The man page
>> (http://www.kernel.org/doc/man-pages/online/pages/man2/msgctl.2.html)
>> does indeed say that msgpool is "unused".  But that meant "unused by
>> the kernel" (sorry -- I probably should have worded that text better).
>>  And, as you spotted, the page also wrongly said the value is in
>> bytes.
>>
>> However, making this change affects the ABI.  A userspace application
>> that was previously using msgctl(IPC_INFO) to retrieve the msgpool
>> field will be affected by the factor-of-1024 change.  I strongly
>> suspect that there no such applications, or certainly none that care
>> (since this value is unused by the kernel).  But was there a reason
>> for making this change, aside from the fact that the code and the man
>> page didn't agree?
>>
>
> No, that was the only reason.
> Should I repost a patch to set it back as it used to be?

On the one hand, I'd be inclined to leave things as they were pre
2.6.26.  On the other hand, I believe that on other systems that have
the limit, msgpool is a limit in bytes.  (But documentation of these
details on other systems is very thin on the ground.)  I wonder if
anyone else has some knowledge here?


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Found a bug? http://www.kernel.org/doc/man-pages/reporting_bugs.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
