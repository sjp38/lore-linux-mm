Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id D797F6B000A
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 21:58:36 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id l11-v6so15988288oth.1
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 18:58:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n21-v6sor13725976otf.276.2018.06.11.18.58.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Jun 2018 18:58:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180612015025.GA25302@hori1.linux.bs1.fc.nec.co.jp>
References: <20180605141104.GF19202@dhcp22.suse.cz> <CAPcyv4iGd56kc2NG5GDYMqW740RNr7NZr9DRft==fPxPyieq7Q@mail.gmail.com>
 <20180606073910.GB32433@dhcp22.suse.cz> <CAPcyv4hA2Na7wyuyLZSWG5s_4+pEv6aMApk23d2iO1vhFx92XQ@mail.gmail.com>
 <20180607143724.GS32433@dhcp22.suse.cz> <CAPcyv4jnyuC-yjuSgu4qKtzB0h9yYMZDsg5Rqqa=HTCY9KM_gw@mail.gmail.com>
 <20180611075004.GH13364@dhcp22.suse.cz> <CAPcyv4gSTMEi5XdzLQZqxMMKCcwF=me02wCiRtAAXSiy2CPGJA@mail.gmail.com>
 <20180611145636.GP13364@dhcp22.suse.cz> <CAPcyv4hnPRk0hTGctHB4tBnyL_27x3DwPUVwhZ+L7c-=1Xdf6Q@mail.gmail.com>
 <20180612015025.GA25302@hori1.linux.bs1.fc.nec.co.jp>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 11 Jun 2018 18:58:35 -0700
Message-ID: <CAPcyv4g2qS-Tp4CiP5TUWsMAepUwUk-zFBAWrjJgtU=c7hZ0Kw@mail.gmail.com>
Subject: Re: [PATCH v2 00/11] mm: Teach memory_failure() about ZONE_DEVICE pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, "linux-edac@vger.kernel.org" <linux-edac@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@alien8.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Hellwig <hch@lst.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ingo Molnar <mingo@redhat.com>, Souptick Joarder <jrdr.linux@gmail.com>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>

On Mon, Jun 11, 2018 at 6:50 PM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> On Mon, Jun 11, 2018 at 08:19:54AM -0700, Dan Williams wrote:
[..]
> Anyway I'll find time to work on this, while now I'm testing the dax
> support patches and fixing a bug I found recently.

Ok, with this and other review feedback these patches are not ready
for 4.18. I'll circle back for 4.19 and we can try again.

Thanks for taking a look!
