Subject: Re: 2.6.0-mm2 (compile stats)
From: John Cherry <cherry@osdl.org>
In-Reply-To: <20031229013223.75c531ed.akpm@osdl.org>
References: <20031229013223.75c531ed.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1072833952.20705.35.camel@cherrytest.pdx.osdl.net>
Mime-Version: 1.0
Date: Tue, 30 Dec 2003 17:25:52 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Compile stats are now posted for the last couple mm builds.

Linux 2.6 (mm tree) Compile Statistics (gcc 3.2.2)
Warnings/Errors Summary

Kernel            bzImage   bzImage  bzImage  modules  bzImage  modules
                (defconfig) (allno) (allyes) (allyes) (allmod) (allmod)
--------------- ---------- -------- -------- -------- -------- --------
2.6.0-mm2         0w/0e     0w/0e   161w/ 5e  12w/0e   3w/0e    189w/0e
2.6.0-mm1         0w/0e     0w/0e   173w/ 0e  12w/0e   3w/0e    212w/0e
2.6.0-test11-mm1  0w/0e    17w/8e   172w/ 0e  12w/0e   3w/0e    211w/0e
2.6.0-test10-mm1  0w/0e     0w/0e   172w/ 0e  12w/0e   3w/0e    211w/0e
2.6.0-test9-mm5   0w/0e     0w/0e   172w/ 0e  12w/0e   3w/0e    211w/0e
2.6.0-test9-mm4   2w/0e     0w/0e   174w/ 0e  12w/0e   3w/0e    213w/0e
2.6.0-test9-mm3   0w/0e     0w/0e   172w/ 0e  12w/0e   3w/0e    211w/0e
2.6.0-test9-mm2   0w/0e     0w/0e   172w/ 0e  12w/0e   3w/0e    211w/1e
2.6.0-test9-mm1   0w/0e     0w/0e   179w/ 1e  12w/0e   3w/0e    213w/1e
2.6.0-test8-mm1   0w/0e     0w/0e   183w/ 1e  13w/0e   3w/0e    223w/1e
2.6.0-test7-mm1   0w/0e     1w/0e   176w/ 1e   9w/0e   3w/0e    231w/1e
2.6.0-test6-mm4   0w/0e     1w/0e   179w/ 1e   9w/0e   3w/0e    234w/1e
2.6.0-test6-mm3   0w/0e     1w/0e   178w/ 1e   9w/0e   3w/0e    252w/2e
2.6.0-test6-mm2   0w/0e     1w/0e   179w/ 1e   9w/0e   3w/0e    252w/2e
2.6.0-test6-mm1   0w/0e     1w/0e   179w/ 1e   9w/0e   3w/0e    252w/2e

Web page with links to complete details:
   http://developer.osdl.org/cherry/compile/

John


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
