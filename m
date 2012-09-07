Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 6CCAB6B006C
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 20:00:02 -0400 (EDT)
Received: by iec9 with SMTP id 9so4949305iec.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 17:00:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAAmzW4NOMyZ8GPb7NcJBvcRD55JTFRhVxG7yyo29YcRWKm3mwA@mail.gmail.com>
References: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com>
	<1346885323-15689-3-git-send-email-elezegarcia@gmail.com>
	<alpine.DEB.2.00.1209051757250.7625@chino.kir.corp.google.com>
	<CALF0-+WgAicBOv6beNdfkFFS-DuAZMQfH9r9iYG5tkfFNSzRZg@mail.gmail.com>
	<CAAmzW4NOMyZ8GPb7NcJBvcRD55JTFRhVxG7yyo29YcRWKm3mwA@mail.gmail.com>
Date: Thu, 6 Sep 2012 21:00:01 -0300
Message-ID: <CALF0-+XHSaZW_mBq_WQAmxOTK46zXx1gEx-wX6Ho1BAskGmhmQ@mail.gmail.com>
Subject: Re: [PATCH 3/5] mm, util: Do strndup_user allocation directly,
 instead of through memdup_user
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

Hi Joonsoo,

On Thu, Sep 6, 2012 at 4:27 PM, JoonSoo Kim <js1304@gmail.com> wrote:
> 2012/9/6 Ezequiel Garcia <elezegarcia@gmail.com>:
>> Hi David,
>>
>> On Wed, Sep 5, 2012 at 9:59 PM, David Rientjes <rientjes@google.com> wrote:
>>> On Wed, 5 Sep 2012, Ezequiel Garcia wrote:
>>>
>>>> I'm not sure this is the best solution,
>>>> but creating another function to reuse between strndup_user
>>>> and memdup_user seemed like an overkill.
>>>>
>>>
>>> It's not, so you'd need to do two things to fix this:
>>>
>>>  - provide a reason why strndup_user() is special compared to other
>>>    common library functions that also allocate memory, and
>>>
>>
>> Sorry, I don't understand what you mean.
>> strndup_user is *not* special than any other function, simply if you use
>> memdup_user for the allocation you will get traces with strndup_user
>> as the caller,
>> and that's not desirable.
>
> I'm not sure that this changed should be needed.

Why do you think this?

> But, if you want to fix this properly, why don't change __krealloc() ?
> It is called by krealloc(), and may return krealloc()'s address.

That's already fixed and applied on Pekka's tree, it's this one:
mm: Use __do_krealloc to do the krealloc job

I think this kind of issues are important, yet overlooked, for kmem
tracing to become
useful. There's a reason we have kmalloc_track_caller, and it would be nice
to have them all trace properly.

Regards,
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
