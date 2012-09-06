Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 16BE06B009D
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 21:06:06 -0400 (EDT)
Received: by iec9 with SMTP id 9so2619171iec.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 18:06:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1209051757250.7625@chino.kir.corp.google.com>
References: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com>
	<1346885323-15689-3-git-send-email-elezegarcia@gmail.com>
	<alpine.DEB.2.00.1209051757250.7625@chino.kir.corp.google.com>
Date: Wed, 5 Sep 2012 22:06:05 -0300
Message-ID: <CALF0-+WgAicBOv6beNdfkFFS-DuAZMQfH9r9iYG5tkfFNSzRZg@mail.gmail.com>
Subject: Re: [PATCH 3/5] mm, util: Do strndup_user allocation directly,
 instead of through memdup_user
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

Hi David,

On Wed, Sep 5, 2012 at 9:59 PM, David Rientjes <rientjes@google.com> wrote:
> On Wed, 5 Sep 2012, Ezequiel Garcia wrote:
>
>> I'm not sure this is the best solution,
>> but creating another function to reuse between strndup_user
>> and memdup_user seemed like an overkill.
>>
>
> It's not, so you'd need to do two things to fix this:
>
>  - provide a reason why strndup_user() is special compared to other
>    common library functions that also allocate memory, and
>

Sorry, I don't understand what you mean.
strndup_user is *not* special than any other function, simply if you use
memdup_user for the allocation you will get traces with strndup_user
as the caller,
and that's not desirable.

Thanks for reviewing,
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
