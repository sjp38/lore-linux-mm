Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id F061F6B0033
	for <linux-mm@kvack.org>; Sun, 26 Nov 2017 20:24:49 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 70so27636490pgf.5
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 17:24:49 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id h74si24169775pfe.172.2017.11.26.17.24.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 26 Nov 2017 17:24:48 -0800 (PST)
From: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Subject: Re: [PATCH 01/11] Initialize the mapping of KASan shadow memory
Date: Mon, 27 Nov 2017 01:23:50 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C006B4D7@dggemm510-mbs.china.huawei.com>
References: <87375eqobb.fsf@on-the-bus.cambridge.arm.com>
 <B8AC3E80E903784988AB3003E3E97330C0063816@dggemm510-mbs.china.huawei.com>
 <20171117073556.GB28855@cbox>
 <B8AC3E80E903784988AB3003E3E97330C00638D4@dggemm510-mbs.china.huawei.com>
 <20171118134841.3f6c9183@why.wild-wind.fr.eu.org>
 <B8AC3E80E903784988AB3003E3E97330C0068F12@dggemm510-mbx.china.huawei.com>
 <20171121122938.sydii3i36jbzi7x4@lakrids.cambridge.arm.com>
 <B8AC3E80E903784988AB3003E3E97330C0069032@dggemm510-mbx.china.huawei.com>
 <757534e5-fcea-3eb4-3c8d-b8c7e709f555@arm.com>
 <B8AC3E80E903784988AB3003E3E97330C0069083@dggemm510-mbx.china.huawei.com>
 <20171123152218.GQ31757@n2100.armlinux.org.uk>
In-Reply-To: <20171123152218.GQ31757@n2100.armlinux.org.uk>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Marc Zyngier <marc.zyngier@arm.com>, Mark Rutland <mark.rutland@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "mhocko@suse.com" <mhocko@suse.com>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "glider@google.com" <glider@google.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "mingo@kernel.org" <mingo@kernel.org>, Christoffer Dall <cdall@linaro.org>, "opendmb@gmail.com" <opendmb@gmail.com>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, Dailei <dylix.dailei@huawei.com>, "dvyukov@google.com" <dvyukov@google.com>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "labbott@redhat.com" <labbott@redhat.com>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, Zengweilin <zengweilin@huawei.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, Heshaoliang <heshaoliang@huawei.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jiazhenghua <jiazhenghua@huawei.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "thgarnie@google.com" <thgarnie@google.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

On Nov 23, 2017  23:22  Russell King - ARM Linux [mailto:linux@armlinux.org=
.uk]  wrote:
>Please pay attention to the project coding style whenever creating code
>for a program.  It doesn't matter what the project coding style is, as
>long as you write your code to match the style that is already there.
>
>For the kernel, that is: tabs not spaces for indentation of code.
>You seem to be using a variable number of spaces for all the new code
>above.
>
>Some of it seems to be your email client thinking it knows better about
>white space - and such behaviours basically makes patches unapplyable.
>See Documentation/process/email-clients.rst for hints about email
>clients.
Thanks for your review.
I'm going to change it in the new version. =20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
