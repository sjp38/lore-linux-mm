Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 289EF6B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 02:00:52 -0400 (EDT)
Received: by vcbfk14 with SMTP id fk14so320159vcb.14
        for <linux-mm@kvack.org>; Mon, 12 Mar 2012 23:00:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120312.225302.488696931454771146.davem@davemloft.net>
References: <1331617001-20906-1-git-send-email-apenwarr@gmail.com> <20120312.225302.488696931454771146.davem@davemloft.net>
From: Avery Pennarun <apenwarr@gmail.com>
Date: Tue, 13 Mar 2012 02:00:30 -0400
Message-ID: <CAHqTa-3DiZhd_yoRTzp2Np0Rp=_zrfL7CbN_twu+ZZeu7f4ENg@mail.gmail.com>
Subject: Re: [PATCH 0/5] Persist printk buffer across reboots.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: akpm@linux-foundation.org, josh@joshtriplett.org, paulmck@linux.vnet.ibm.com, mingo@elte.hu, a.p.zijlstra@chello.nl, fdinitto@redhat.com, hannes@cmpxchg.org, olaf@aepfle.de, paul.gortmaker@windriver.com, tj@kernel.org, hpa@linux.intel.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 13, 2012 at 1:53 AM, David Miller <davem@davemloft.net> wrote:
> From: Avery Pennarun <apenwarr@gmail.com>
> Date: Tue, 13 Mar 2012 01:36:36 -0400
>
>> The last patch in this series implements a new CONFIG_PRINTK_PERSIST opt=
ion
>> that, when enabled, puts the printk buffer in a well-defined memory loca=
tion
>> so that we can keep appending to it after a reboot. =A0The upshot is tha=
t,
>> even after a kernel panic or non-panic hard lockup, on the next boot
>> userspace will be able to grab the kernel messages leading up to it. =A0=
It
>> could then upload the messages to a server (for example) to keep crash
>> statistics.
>
> On some platforms there are formal ways to reserve areas of memory
> such that the bootup firmware will know to not touch it on soft resets
> no matter what. =A0For example, on Sparc there are OpenFirmware calls to
> set aside such an area of soft-reset preserved memory.
>
> I think some formal agreement with the system firmware is a lot better
> when available, and should be explicitly accomodated in these changes
> so that those of us with such facilities can very easily hook it up.

Sounds good to me.  Do you have any pointers?  Just use an
early_param?  If we see the early_param but we can't reserve the
requested address, should we fall back to probing or disable the
PRINTK_PERSIST mode entirely?

Thanks,

Avery

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
