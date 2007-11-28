Date: Wed, 28 Nov 2007 13:49:31 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: a questio about slab: double free detected in cache
Message-ID: <20071128184931.GE18686@redhat.com>
References: <733610bd0711272059s5ba0954g5f7bfa7cb0324e02@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <733610bd0711272059s5ba0954g5f7bfa7cb0324e02@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?utf-8?B?5pet5Lic546L?= <wangeastsun@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 28, 2007 at 12:59:47PM +0800, ae?-a,?c?? wrote:
 
 > The environment of a device  is as below:
 > 
 > kernel version is 2.6.14, it is OS distribution kernel Fedora 2. The
 > file system is ext3. The cpu type is arm9.

I doubt you'll find anyone who really cares about fixing bugs in
kernels over two years old unless you can repeat them on
current kernel versions.
 
	Dave

-- 
http://www.codemonkey.org.uk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
