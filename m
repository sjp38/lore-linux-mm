Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CCA406B0253
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 20:19:34 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id k4so5773869pgq.15
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 17:19:34 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id v80si8188196pgb.104.2018.01.12.17.19.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jan 2018 17:19:33 -0800 (PST)
Subject: Re: [PATCH] security/Kconfig: Replace pagetable-isolation.txt
 reference with pti.txt
References: <9b21ce8f-625c-6915-654b-42334cf38e99@linux.intel.com>
 <3009cc8ccbddcd897ec1e0cb6dda524929de0d14.1515799398.git.wking@tremily.us>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <68769b20-2be5-85b7-f21c-cc9094de547c@linux.intel.com>
Date: Fri, 12 Jan 2018 17:19:32 -0800
MIME-Version: 1.0
In-Reply-To: <3009cc8ccbddcd897ec1e0cb6dda524929de0d14.1515799398.git.wking@tremily.us>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "W. Trevor King" <wking@tremily.us>, linux-security-module@vger.kernel.org
Cc: James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/12/2018 03:24 PM, W. Trevor King wrote:
> The reference landed with the config option in 385ce0ea (x86/mm/pti:
> Add Kconfig, 2017-12-04), but the referenced file was not committed
> then.  It eventually landed in 01c9b17b (x86/Documentation: Add PTI
> description, 2018-01-05) as pti.txt.
> 
> Signed-off-by: W. Trevor King <wking@tremily.us>
> ---
> On Fri, Jan 12, 2018 at 03:10:53PM -0800, Dave Hansen wrote:
>> There is a new file in -tip:
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git/commit/?h=x86/pti&id=01c9b17bf673b05bb401b76ec763e9730ccf1376
>>
>> If you're going to patch this, please send an update to -tip that
>> corrects the filename.
> 
> Here you go :).

Feel free to add my Acked-by.  And please send to x86@kernel.org.  They
need to put this in after the addition of the documentation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
