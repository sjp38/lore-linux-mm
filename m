Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id E7537900016
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 15:50:35 -0400 (EDT)
Received: by laew7 with SMTP id w7so41810084lae.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 12:50:35 -0700 (PDT)
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com. [209.85.217.175])
        by mx.google.com with ESMTPS id rd3si15918272lac.167.2015.06.02.12.50.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 12:50:34 -0700 (PDT)
Received: by lbbqq2 with SMTP id qq2so111426142lbb.3
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 12:50:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150602194354.GM23057@wotan.suse.de>
References: <1433187393-22688-1-git-send-email-toshi.kani@hp.com>
 <20150602162103.GL23057@wotan.suse.de> <1433270808.23540.155.camel@misato.fc.hp.com>
 <20150602194354.GM23057@wotan.suse.de>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 2 Jun 2015 12:50:09 -0700
Message-ID: <CALCETrXho_xx27yq_Ji+xpD785xWGNpL-Tgbn17S8RbK6unQWA@mail.gmail.com>
Subject: Re: [PATCH v12 0/10] Support Write-Through mapping on x86
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@suse.com>
Cc: Toshi Kani <toshi.kani@hp.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "Elliott, Robert (Server Storage)" <Elliott@hp.com>, Christoph Hellwig <hch@lst.de>

On Tue, Jun 2, 2015 at 12:43 PM, Luis R. Rodriguez <mcgrof@suse.com> wrote:
> On Tue, Jun 02, 2015 at 12:46:48PM -0600, Toshi Kani wrote:
>> On Tue, 2015-06-02 at 18:21 +0200, Luis R. Rodriguez wrote:
>> > On Mon, Jun 01, 2015 at 01:36:23PM -0600, Toshi Kani wrote:
>> > > This patchset adds support of Write-Through (WT) mapping on x86.
>> > > The study below shows that using WT mapping may be useful for
>> > > non-volatile memory.
>> > >
>> > > http://www.hpl.hp.com/techreports/2012/HPL-2012-236.pdf
>> > >
>> > > The patchset consists of the following changes.
>> > >  - Patch 1/10 to 6/10 add ioremap_wt()
>> > >  - Patch 7/10 adds pgprot_writethrough()
>> > >  - Patch 8/10 to 9/10 add set_memory_wt()
>> > >  - Patch 10/10 changes the pmem driver to call ioremap_wt()
>> > >
>> > > All new/modified interfaces have been tested.
>> > >
>> > > The patchset is based on:
>> > > git://git.kernel.org/pub/scm/linux/kernel/git/bp/bp.git#tip-mm-2
>> >
>> > While at it can you also look at:
>> >
>> > mcgrof@ergon ~/linux-next (git::master)$ git grep -4 "writethrough" drivers/infiniband/
>>
>> Thanks for checking this.  The inifiniband driver uses WT mappings on
>> powerpc without proper WT interfaces defined.
>
> Right.
>
>>  They can be cleaned up by
>> a separate patch series to support WT on powerpc in the same way after
>> this patchset (support WT on x86) is settled.
>
> Who's gonna do that work though? How much work is it ? Is it too much to ask
> to roll it in this series?
>

I think the driver maintainers should do it.  For all I know,
something will go horribly wrong if those drivers suddenly start using
WT on x86.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
