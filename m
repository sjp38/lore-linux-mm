Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0CFE16B007E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 01:31:58 -0400 (EDT)
Received: by ywm39 with SMTP id 39so2119670ywm.14
        for <linux-mm@kvack.org>; Mon, 11 Jul 2011 22:31:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110528005640.9076c0b1.akpm@linux-foundation.org>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
	<20110528005640.9076c0b1.akpm@linux-foundation.org>
Date: Tue, 12 Jul 2011 11:01:53 +0530
Message-ID: <CADGdYn7VCKemAgdbNw76vj7E9swxtK=z8+9uv=omG89QNE0uxg@mail.gmail.com>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory Power Management
From: amit kachhap <amit.kachhap@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ankita Garg <ankita@in.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, thomas.abraham@linaro.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org

Hi All,

In response to the discussion about power savings with memory regions
features following measurements are done.

Title:
On a system with 2GB memory , 1GB is static and the other 1GB in
various power states.

Brief environment description:
Samsung smdk-exynos board is used for this work and full board level
power consumption is measured that comprises of cpu and other
components. It has 2 DMC's(Dynamic memory controller) with each
supporting 1 GB DDR3 memory. Power characteristics of DMC0 controlled
memory remain same but memory controlled by DMC1 is changed to 4
different power states. The following numbers describe the maximum
power savings measured after executing the software from DMC0
controlled memory which changes the power states of DMC1 controlled
memory. Here the actual numbers are not mentioned but the percentage
power savings is shown in reference to the change in overall power
consumption. The memory region patches are expected to facilitate
transition of memory into into one of the following low power states.

1) Percentage power savings when DMC1(1GB) moved to self refresh mode
from idle/unaccess mode=3D 2.69%
2) Percentage power savings when DMC1(1GB) moved to precharge mode
from idle/unaccess mode=3D 3.23%
3) Percentage power savings when DMC1(1GB) clock is gated  =3D 6.32%

The above power savings is indicative of the benefits that memory
regions could provide in this platform.

Thanks & Regards,
Amit Daniel Kachhap
Samsung India s/w operations, Bangalore

On Sat, May 28, 2011 at 1:26 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 27 May 2011 18:01:28 +0530 Ankita Garg <ankita@in.ibm.com> wrote:
>
>> This patchset proposes a generic memory regions infrastructure that can =
be
>> used to tag boundaries of memory blocks which belongs to a specific memo=
ry
>> power management domain and further enable exploitation of platform memo=
ry
>> power management capabilities.
>
> A couple of quick thoughts...
>
> I'm seeing no estimate of how much energy we might save when this work
> is completed. =A0But saving energy is the entire point of the entire
> patchset! =A0So please spend some time thinking about that and update and
> maintain the [patch 0/n] description so others can get some idea of the
> benefit we might get from all of this. =A0That estimate should include an
> estimate of what proportion of machines are likely to have hardware
> which can use this feature and in what timeframe.
>
> IOW, if it saves one microwatt on 0.001% of machines, not interested ;)
>
>
> Also, all this code appears to be enabled on all machines? =A0So machines
> which don't have the requisite hardware still carry any additional
> overhead which is added here. =A0I can see that ifdeffing a feature like
> this would be ghastly but please also have a think about the
> implications of this and add that discussion also.
>
> If possible, it would be good to think up some microbenchmarks which
> probe the worst-case performance impact and describe those and present
> the results. =A0So others can gain an understanding of the runtime costs.
>
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
