Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 52B666B0006
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 11:19:56 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b2-v6so10806438oib.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 08:19:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u15-v6sor16516813oia.89.2018.06.11.08.19.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Jun 2018 08:19:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180611145636.GP13364@dhcp22.suse.cz>
References: <20180604124031.GP19202@dhcp22.suse.cz> <CAPcyv4gLxz7Ke6ApXoATDN31PSGwTgNRLTX-u1dtT3d+6jmzjw@mail.gmail.com>
 <20180605141104.GF19202@dhcp22.suse.cz> <CAPcyv4iGd56kc2NG5GDYMqW740RNr7NZr9DRft==fPxPyieq7Q@mail.gmail.com>
 <20180606073910.GB32433@dhcp22.suse.cz> <CAPcyv4hA2Na7wyuyLZSWG5s_4+pEv6aMApk23d2iO1vhFx92XQ@mail.gmail.com>
 <20180607143724.GS32433@dhcp22.suse.cz> <CAPcyv4jnyuC-yjuSgu4qKtzB0h9yYMZDsg5Rqqa=HTCY9KM_gw@mail.gmail.com>
 <20180611075004.GH13364@dhcp22.suse.cz> <CAPcyv4gSTMEi5XdzLQZqxMMKCcwF=me02wCiRtAAXSiy2CPGJA@mail.gmail.com>
 <20180611145636.GP13364@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 11 Jun 2018 08:19:54 -0700
Message-ID: <CAPcyv4hnPRk0hTGctHB4tBnyL_27x3DwPUVwhZ+L7c-=1Xdf6Q@mail.gmail.com>
Subject: Re: [PATCH v2 00/11] mm: Teach memory_failure() about ZONE_DEVICE pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, linux-edac@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@alien8.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Hellwig <hch@lst.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ingo Molnar <mingo@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Souptick Joarder <jrdr.linux@gmail.com>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>

On Mon, Jun 11, 2018 at 7:56 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 11-06-18 07:44:39, Dan Williams wrote:
> [...]
>> I'm still trying to understand the next level of detail on where you
>> think the design should go next? Is it just the HWPoison page flag?
>> Are you concerned about supporting greater than PAGE_SIZE poison?
>
> I simply do not want to check for HWPoison at zillion of places and have
> each type of page to have some special handling which can get wrong very
> easily. I am not clear on details here, this is something for users of
> hwpoison to define what is the reasonable scenarios when the feature is
> useful and turn that into a feature list that can be actually turned
> into a design document. See the different from let's put some more on
> top approach...
>

So you want me to pay the toll of writing a design document justifying
all the existing use cases of HWPoison before we fix the DAX bugs, and
the design document may or may not result in any substantive change to
these patches?

Naoya or Andi, can you chime in here?
