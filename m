Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4DFFB6B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 12:37:15 -0400 (EDT)
Received: by obbea2 with SMTP id ea2so107831828obb.3
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 09:37:15 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id pm10si9104191obc.105.2015.06.01.09.37.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jun 2015 09:37:14 -0700 (PDT)
Message-ID: <1433175458.23540.111.camel@misato.fc.hp.com>
Subject: Re: [PATCH 1/4] x86/pat: Untangle pat_init()
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 01 Jun 2015 10:17:38 -0600
In-Reply-To: <1433065686-20922-1-git-send-email-bp@alien8.de>
References: <20150531094655.GA20440@pd.tnic>
	 <1433065686-20922-1-git-send-email-bp@alien8.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, arnd@arndb.de, Elliott@hp.com, hch@lst.de, hmh@hmh.eng.br, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, jgross@suse.com, konrad.wilk@oracle.com, linux-mm <linux-mm@kvack.org>, linux-nvdimm@lists.01.org, "Luis R. Rodriguez" <mcgrof@suse.com>, stefan.bader@canonical.com, Thomas Gleixner <tglx@linutronix.de>, x86-ml <x86@kernel.org>, yigal@plexistor.com

On Sun, 2015-05-31 at 11:48 +0200, Borislav Petkov wrote:
> From: Borislav Petkov <bp@suse.de>
> 
> Split it into a BSP and AP version which makes the PAT initialization
> path actually readable again.
> 
> Signed-off-by: Borislav Petkov <bp@suse.de>

Reviewed-by: Toshi Kani <toshi.kani@hp.com>

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
