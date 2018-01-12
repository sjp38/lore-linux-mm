Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0336B0268
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 18:10:58 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id p89so6176580pfk.5
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 15:10:58 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id z8si117193plo.762.2018.01.12.15.10.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jan 2018 15:10:57 -0800 (PST)
Subject: Re: [PATCH] security/Kconfig: Remove pagetable-isolation.txt
 reference
References: <0ccf9a4d2e42bcb823ab877e4fb21274f27878bd.1515794059.git.wking@tremily.us>
 <alpine.LFD.2.20.1801131006520.13286@localhost>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <9b21ce8f-625c-6915-654b-42334cf38e99@linux.intel.com>
Date: Fri, 12 Jan 2018 15:10:53 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.20.1801131006520.13286@localhost>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morris <james.l.morris@oracle.com>, "W. Trevor King" <wking@tremily.us>
Cc: linux-security-module@vger.kernel.org, "Serge E. Hallyn" <serge@hallyn.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/12/2018 03:06 PM, James Morris wrote:
> On Fri, 12 Jan 2018, W. Trevor King wrote:
> 
>> The reference landed with the config option in 385ce0ea (x86/mm/pti:
>> Add Kconfig, 2017-12-04), but the referenced file was never committed.
>>
>> Signed-off-by: W. Trevor King <wking@tremily.us>
> 
> Acked-by: James Morris <james.l.morris@oracle.com>

There is a new file in -tip:

https://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git/commit/?h=x86/pti&id=01c9b17bf673b05bb401b76ec763e9730ccf1376

If you're going to patch this, please send an update to -tip that corrects the filename.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
