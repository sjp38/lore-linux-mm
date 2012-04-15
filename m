Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id AE1EF6B004A
	for <linux-mm@kvack.org>; Sun, 15 Apr 2012 08:10:02 -0400 (EDT)
Received: by lbbgp10 with SMTP id gp10so1034952lbb.14
        for <linux-mm@kvack.org>; Sun, 15 Apr 2012 05:10:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334490429.67558.YahooMailNeo@web162006.mail.bf1.yahoo.com>
References: <1334483226.20721.YahooMailNeo@web162003.mail.bf1.yahoo.com>
	<CAFLxGvwJCMoiXFn3OgwiX+B50FTzGZmo6eG3xQ1KaPsEVZVA1g@mail.gmail.com>
	<1334490429.67558.YahooMailNeo@web162006.mail.bf1.yahoo.com>
Date: Sun, 15 Apr 2012 14:10:00 +0200
Message-ID: <CAFLxGvz5tmEi-39CZbJN+0zNd3ZpHXzZcNSFUpUWS_aMDJ4t6Q@mail.gmail.com>
Subject: Re: [NEW]: Introducing shrink_all_memory from user space
From: richard -rw- weinberger <richard.weinberger@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "pintu.k@samsung.com" <pintu.k@samsung.com>

On Sun, Apr 15, 2012 at 1:47 PM, PINTU KUMAR <pintu_agarwal@yahoo.com> wrote:
> Moreover, this is mainly meant for mobile phones where there is only *one* user.

I see. Jet another awful hack.
Mobile phones are nothing special. They are computers.

>>
>> If we expose it to user space *every* program/user will try too free
>> memory such that it
>> can use more.
>> Can you see the problem?
>>
> As indicated above, every program/user cannot use it, as it requires root privileges.
> Ok, you mean to say, every driver can call "shrink_all_memory" simultaneously??
> Well, we can implement locking for that.
> Anyways, I wrote a simple script to do this (echo 512 > /dev/shrinkmem) in a loop for 20 times from 2 different terminal (as root) and it works.
> I cannot see any problem.

Every program which is allowed to use this interface will (ab)use it.
Anyway, by exposing this interface to user space (or kernel modules)
you'll confuse the VM system.

-- 
Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
