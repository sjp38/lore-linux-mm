Received: by rv-out-0708.google.com with SMTP id f25so2637852rvb.26
        for <linux-mm@kvack.org>; Wed, 21 May 2008 03:47:22 -0700 (PDT)
Message-ID: <cfd18e0f0805210347j7c46fb8au236c50000e39fa08@mail.gmail.com>
Date: Wed, 21 May 2008 12:47:22 +0200
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

Nadia,

I think for the moment it might be best to revert that change, since
there's no actual need to change things.  I've updated the man page to
say that this value is in kibibytes.

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Found a bug? http://www.kernel.org/doc/man-pages/reporting_bugs.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
