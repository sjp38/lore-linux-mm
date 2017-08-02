Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 35AC56B05AC
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 04:30:30 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w63so5158165wrc.5
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 01:30:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z19si25100739wrc.101.2017.08.02.01.30.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Aug 2017 01:30:29 -0700 (PDT)
Subject: Re: [PATCHv2 08/10] x86/mm: Replace compile-time checks for 5-level
 with runtime-time
References: <20170718141517.52202-9-kirill.shutemov@linux.intel.com>
 <6841c4f3-6794-f0ac-9af9-0ceb56e49653@suse.com>
 <20170725090538.26sbgb4npkztsqj3@black.fi.intel.com>
 <39cb1e36-f94e-32ea-c94a-2daddcbf3408@suse.com>
 <20170726164335.xaajz5ltzhncju26@node.shutemov.name>
 <c450949e-bd79-c9c9-797e-be6b2c7b1e5f@suse.com>
 <20170801144414.rd67k2g2cz46nlow@black.fi.intel.com>
 <d7d46a3c-1a01-1f35-99ed-6c1587275433@suse.com>
 <20170801191144.k333twdie52arpwt@black.fi.intel.com>
 <2c425437-f887-8a7e-9bce-36338c0979d0@suse.com>
 <20170802081758.hmlmxv4xrq5lxuxl@node.shutemov.name>
From: Juergen Gross <jgross@suse.com>
Message-ID: <bd4169dc-dead-2e52-6a63-c2579eb96379@suse.com>
Date: Wed, 2 Aug 2017 10:30:26 +0200
MIME-Version: 1.0
In-Reply-To: <20170802081758.hmlmxv4xrq5lxuxl@node.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/08/17 10:17, Kirill A. Shutemov wrote:
> On Wed, Aug 02, 2017 at 09:44:54AM +0200, Juergen Gross wrote:
>> That did the trick!
>>
>> PV domU is coming up now with a 5-level paging enabled kernel.
> 
> Thanks a lot for helping me up with it.
> 
> I'll integrate the fixes into patchset.
> 
> Just, for clarification XEN_PVH works too, right?

Yes.


Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
