Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 70B2B6B005C
	for <linux-mm@kvack.org>; Sat, 10 Dec 2011 06:13:25 -0500 (EST)
Message-ID: <4EE33EC2.6050508@redhat.com>
Date: Sat, 10 Dec 2011 09:13:06 -0200
From: Mauro Carvalho Chehab <mchehab@redhat.com>
MIME-Version: 1.0
Subject: Re: [Linaro-mm-sig] [RFC v2 1/2] dma-buf: Introduce dma buffer sharing
 mechanism
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com> <1322816252-19955-2-git-send-email-sumit.semwal@ti.com> <201112051718.48324.arnd@arndb.de> <20111209225056.GL7969@morell.nvidia.com>
In-Reply-To: <20111209225056.GL7969@morell.nvidia.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Morell <rmorell@nvidia.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Sumit Semwal <sumit.semwal@ti.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "jesse.barker@linaro.org" <jesse.barker@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "daniel@ffwll.ch" <daniel@ffwll.ch>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

On 09-12-2011 20:50, Robert Morell wrote:
> On Mon, Dec 05, 2011 at 09:18:48AM -0800, Arnd Bergmann wrote:
>> On Friday 02 December 2011, Sumit Semwal wrote:
>>> This is the first step in defining a dma buffer sharing mechanism.
>>
> [...]
>>
>>> +	return dmabuf;
>>> +}
>>> +EXPORT_SYMBOL(dma_buf_export);
>>
>> I agree with Konrad, this should definitely be EXPORT_SYMBOL_GPL,
>> because it's really a low-level function that I would expect
>> to get used by in-kernel subsystems providing the feature to
>> users and having back-end drivers, but it's not the kind of thing
>> we want out-of-tree drivers to mess with.
>
> Is this really necessary?  If this is intended to be a
> lowest-common-denominator between many drivers to allow buffer sharing,
> it seems like it needs to be able to be usable by all drivers.
>
> If the interface is not accessible then I fear many drivers will be
> forced to continue to roll their own buffer sharing mechanisms (which is
> exactly what we're trying to avoid here, needless to say).

Doing a buffer sharing with something that is not GPL is not fun, as, if any
issue rises there, it would be impossible to discover if the problem is either
at the closed-source driver or at the open source one. At the time I was using
the Nvidia proprietary driver, it was very common to have unexplained issues
caused likely by bad code there at the buffer management code, causing X
applications and extensions (like xv) to break.

We should really make this EXPORT_SYMBOL_GPL(), in order to be able to latter
debug future share buffer issues, when needed.

Regards,
Mauro

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
