Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 2957D6B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:09:52 -0500 (EST)
Received: by qam2 with SMTP id 2so1830110qam.14
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 11:09:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120229150041.62c1feeb.kamezawa.hiroyu@jp.fujitsu.com>
References: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org>
	<1330383533-20711-5-git-send-email-ssouhlal@FreeBSD.org>
	<20120229150041.62c1feeb.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 29 Feb 2012 11:09:50 -0800
Message-ID: <CABCjUKBHjLHKUmW6_r0SOyw42WfV0zNO7Kd7FhhRQTT6jZdyeQ@mail.gmail.com>
Subject: Re: [PATCH 04/10] memcg: Introduce __GFP_NOACCOUNT.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, glommer@parallels.com, penberg@kernel.org, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org

On Tue, Feb 28, 2012 at 10:00 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 27 Feb 2012 14:58:47 -0800
> Suleiman Souhlal <ssouhlal@FreeBSD.org> wrote:
>
>> This is used to indicate that we don't want an allocation to be accounte=
d
>> to the current cgroup.
>>
>> Signed-off-by: Suleiman Souhlal <suleiman@google.com>
>
> I don't like this.
>
> Please add
>
> ___GFP_ACCOUNT =A0"account this allocation to memcg"
>
> Or make this as slab's flag if this work is for slab allocation.

We would like to account for all the slab allocations that happen in
process context.

Manually marking every single allocation or kmem_cache with a GFP flag
really doesn't seem like the right thing to do..

Can you explain why you don't like this flag?

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
