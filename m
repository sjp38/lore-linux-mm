Date: Sat, 01 Mar 2008 17:22:03 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [rfc 02/10] Pageflags: Introduce macros to generate page flag functions
In-Reply-To: <20080301040813.835000741@sgi.com>
References: <20080301040755.268426038@sgi.com> <20080301040813.835000741@sgi.com>
Message-Id: <20080301171834.5292.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

> TESTSETFLAG		Create additional test and set function
> TESTCLEARFLAG		Create additional test and clear function
> TESTPAGEFLAG		Create additional atomic set function
> SETPAGEFLAG		Create additional atomic clear function
> __TESTPAGEFLAG		Create additional atomic set function
> __SETPAGEFLAG		Create additional atomic clear function

your intention was

TESTSETFLAG		Create additional test and set function
TESTCLEARFLAG		Create additional test and clear function
TESTPAGEFLAG		Create additional atomic test function
SETPAGEFLAG		Create additional atomic set function
CLEARPAGEFLAG		Create additional atomic clear function
__TESTPAGEFLAG		Create additional non-atomic test function
__SETPAGEFLAG		Create additional non-atomic set function
__CLEARPAGEFLAG		Create additional non-atomic clear function

right?


- kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
