Subject: Re: 2.6.0-test6-mm2 (compile statistics)
From: John Cherry <cherry@osdl.org>
In-Reply-To: <20031002022341.797361bc.akpm@osdl.org>
References: <20031002022341.797361bc.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1065113020.15172.35.camel@cherrytest.pdx.osdl.net>
Mime-Version: 1.0
Date: 02 Oct 2003 09:43:40 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I added the mm builds to the compile regressions.  The full set of
compile data can be found at:

   http://developer.osdl.org/cherry/compile/mm/index.html

For the -test6 mm builds, the compile regress summary is...

Kernel version: 2.6.0-test6-mm2
Kernel build: 
   Making bzImage (defconfig): 0 warnings, 0 errors
   Making modules (defconfig): 0 warnings, 0 errors
   Making bzImage (allyesconfig): 179 warnings, 13 errors
   Making modules (allyesconfig): 9 warnings, 0 errors
   Making bzImage (allmodconfig): 3 warnings, 0 errors
   Making modules (allmodconfig): 252 warnings, 4 errors

Kernel version: 2.6.0-test6-mm1
Kernel build: 
   Making bzImage (defconfig): 0 warnings, 0 errors
   Making modules (defconfig): 0 warnings, 0 errors
   Making bzImage (allyesconfig): 179 warnings, 11 errors
   Making modules (allyesconfig): 9 warnings, 0 errors
   Making bzImage (allmodconfig): 3 warnings, 0 errors
   Making modules (allmodconfig): 252 warnings, 2 errors

John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
