Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AE5686B004A
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 04:27:01 -0500 (EST)
Received: by qwd7 with SMTP id 7so823062qwd.14
        for <linux-mm@kvack.org>; Wed, 17 Nov 2010 01:27:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101117020759.016741414@intel.com>
References: <20101117020759.016741414@intel.com>
Date: Wed, 17 Nov 2010 01:26:59 -0800
Message-ID: <AANLkTinp4A8U61rgODAKyQpauhgTbv4p55utaoVEQR0Q@mail.gmail.com>
Subject: Re: [0/8,v3] NUMA Hotplug Emulator - Introduction & Feedbacks
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: shaohui.zheng@intel.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Tue, Nov 16, 2010 at 6:07 PM,  <shaohui.zheng@intel.com> wrote:
>
> * WHAT IS HOTPLUG EMULATOR
>
> NUMA hotplug emulator is collectively named for the hotplug emulation
> it is able to emulate NUMA Node Hotplug thru a pure software way. It
> intends to help people easily debug and test node/cpu/memory hotplug
> related stuff on a none-numa-hotplug-support machine, even an UMA machine=
