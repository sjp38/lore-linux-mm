Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 67AED6B0261
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 18:07:13 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id p89so6170357pfk.5
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 15:07:13 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id b187si14276776pgc.815.2018.01.12.15.07.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jan 2018 15:07:12 -0800 (PST)
Date: Sat, 13 Jan 2018 10:06:59 +1100 (AEDT)
From: James Morris <james.l.morris@oracle.com>
Subject: Re: [PATCH] security/Kconfig: Remove pagetable-isolation.txt
 reference
In-Reply-To: <0ccf9a4d2e42bcb823ab877e4fb21274f27878bd.1515794059.git.wking@tremily.us>
Message-ID: <alpine.LFD.2.20.1801131006520.13286@localhost>
References: <0ccf9a4d2e42bcb823ab877e4fb21274f27878bd.1515794059.git.wking@tremily.us>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "W. Trevor King" <wking@tremily.us>
Cc: linux-security-module@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 12 Jan 2018, W. Trevor King wrote:

> The reference landed with the config option in 385ce0ea (x86/mm/pti:
> Add Kconfig, 2017-12-04), but the referenced file was never committed.
> 
> Signed-off-by: W. Trevor King <wking@tremily.us>


Acked-by: James Morris <james.l.morris@oracle.com>


-- 
James Morris
<james.l.morris@oracle.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
