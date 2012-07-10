Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 02F996B0071
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 15:45:58 -0400 (EDT)
Received: by ggm4 with SMTP id 4so490060ggm.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2012 12:45:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CF1C132D-2873-408A-BCC9-B9F57BE6EDDB@linuxfoundation.org>
References: <20120710111756.GA11351@localhost>
	<CF1C132D-2873-408A-BCC9-B9F57BE6EDDB@linuxfoundation.org>
Date: Tue, 10 Jul 2012 22:45:57 +0300
Message-ID: <CAOJsxLG7fWuHeh-KXzG1PHwZRWztQQYvmxgn_97aYBCtqrLWug@mail.gmail.com>
Subject: Re: linux-next: Early crashed kernel on CONFIG_SLOB
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <christoph@linuxfoundation.org>
Cc: "wfg@linux.intel.com" <wfg@linux.intel.com>, Christoph Lameter <cl@linux.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Jul 10, 2012, at 6:17, wfg@linux.intel.com wrote:
>> This commit crashes the kernel w/o any dmesg output (the attached one
>> is created by the script as a summary for that run). This is very
>> reproducible in kvm for the attached config.
>>
>>        commit 3b0efdfa1e719303536c04d9abca43abeb40f80a
>>        Author: Christoph Lameter <cl@linux.com>
>>        Date:   Wed Jun 13 10:24:57 2012 -0500
>>
>>            mm, sl[aou]b: Extract common fields from struct kmem_cache

On Tue, Jul 10, 2012 at 9:37 PM, Christoph Lameter
<christoph@linuxfoundation.org> wrote:
> I sent a patch yesterday (or was it friday) to fix the issue. Sorry @airport right now.

Which patch is that? I can't seem to find it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
