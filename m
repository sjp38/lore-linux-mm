Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id C4A906B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 18:20:17 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id dq12so970279wgb.24
        for <linux-mm@kvack.org>; Fri, 22 Feb 2013 15:20:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <0000013d02ee5bf7-a2d47cfc-64fb-4faa-b92e-e567aeb6b587-000000@email.amazonses.com>
References: <1361550000-14173-1-git-send-email-glommer@parallels.com>
	<alpine.DEB.2.02.1302221034380.7600@gentwo.org>
	<alpine.DEB.2.02.1302221057430.7600@gentwo.org>
	<0000013d02d9ee83-9b41b446-ee42-4498-863e-33b3175c007c-000000@email.amazonses.com>
	<5127A607.3040603@parallels.com>
	<0000013d02ee5bf7-a2d47cfc-64fb-4faa-b92e-e567aeb6b587-000000@email.amazonses.com>
Date: Sat, 23 Feb 2013 08:20:15 +0900
Message-ID: <CAAmzW4OG6b+7t2S3PUY710CDHkbSb9BWxzxWULm5EzJP4BGEXA@mail.gmail.com>
Subject: Re: [PATCH v2] slub: correctly bootstrap boot caches
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@kernel.org>

2013/2/23 Christoph Lameter <cl@linux.com>:
> On Fri, 22 Feb 2013, Glauber Costa wrote:
>
>> On 02/22/2013 09:01 PM, Christoph Lameter wrote:
>> > Argh. This one was the final version:
>> >
>> > https://patchwork.kernel.org/patch/2009521/
>> >
>>
>> It seems it would work. It is all the same to me.
>> Which one do you prefer?
>
> Flushing seems to be simpler and less code.
>

Hello, Christoph, Glauber.

With flushing, deactivate_slab() occur and it has some overhead to
deactivate objects.
If my patch properly fix this situation, it is better to use mine
which has no overhead.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
