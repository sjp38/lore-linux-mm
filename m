Subject: Re: 2.6.1-mm4 (compile stats)
From: John Cherry <cherry@osdl.org>
In-Reply-To: <20040115225948.6b994a48.akpm@osdl.org>
References: <20040115225948.6b994a48.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1074273246.4603.16.camel@cherrytest.pdx.osdl.net>
Mime-Version: 1.0
Date: Fri, 16 Jan 2004 09:14:06 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linux 2.6 (mm tree) Compile Statistics (gcc 3.2.2)
Warnings/Errors Summary

Kernel            bzImage   bzImage  bzImage  modules  bzImage  modules
                (defconfig) (allno) (allyes) (allyes) (allmod) (allmod)
--------------- ---------- -------- -------- -------- -------- --------
2.6.1-mm4         0w/821e   0w/264e 154w/ 5e   8w/1e   5w/0e    179w/0e
2.6.1-mm3         0w/0e     0w/0e   151w/ 5e  10w/0e   3w/0e    177w/0e
2.6.1-mm2         0w/0e     0w/0e   143w/ 5e  12w/0e   3w/0e    171w/0e
2.6.1-mm1         0w/0e     0w/0e   146w/ 9e  12w/0e   6w/0e    171w/0e
2.6.1-rc2-mm1     0w/0e     0w/0e   149w/ 0e  12w/0e   6w/0e    171w/4e
2.6.1-rc1-mm2     0w/0e     0w/0e   157w/15e  12w/0e   3w/0e    185w/4e
2.6.1-rc1-mm1     0w/0e     0w/0e   156w/10e  12w/0e   3w/0e    184w/2e
2.6.0-mm2         0w/0e     0w/0e   161w/ 0e  12w/0e   3w/0e    189w/0e
2.6.0-mm1         0w/0e     0w/0e   173w/ 0e  12w/0e   3w/0e    212w/0e

Web page with links to complete details:
   http://developer.osdl.org/cherry/compile/

***********************************************************************
For both defconfig and allnoconfig, there are hundreds of the following
warnings:

`CONFIG_X86_L1_CACHE_SHIFT' undeclared here (not in a function)
requested alignment is not a constant

CONFIG_X86_L1_CACHE_SHIFT is not defined in defconfig and allnoconfig.
***********************************************************************

John


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
