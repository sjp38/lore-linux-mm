Received: by fk-out-0910.google.com with SMTP id 18so1481084fkq
        for <linux-mm@kvack.org>; Mon, 08 Oct 2007 18:43:46 -0700 (PDT)
Message-ID: <3d0408630710081843u72807765v47d4b36712b4c9b1@mail.gmail.com>
Date: Tue, 9 Oct 2007 09:43:46 +0800
From: "Yan Zheng" <yanzheng@21cn.com>
Subject: Re: [PATCH]fix VM_CAN_NONLINEAR check in sys_remap_file_pages
In-Reply-To: <20071008105120.4e0e4a85.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <3d0408630710080445j4dea115emdfe29aac26814536@mail.gmail.com>
	 <20071008100456.dbe826d0.akpm@linux-foundation.org>
	 <20071008102843.d20b56d7.randy.dunlap@oracle.com>
	 <20071008105120.4e0e4a85.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ltp-list@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

2007/10/9, Andrew Morton <akpm@linux-foundation.org>:
> Perhaps Yan Zheng can tell us what test was used to demonstrate this?

I found it by review, only do test to check remap_file_pages works
when VM_CAN_NONLINEAR flags is set.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
