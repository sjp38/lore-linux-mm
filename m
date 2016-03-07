Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 993386B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 12:32:12 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id fy10so81748252pac.1
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 09:32:12 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id xv6si4289190pab.1.2016.03.07.09.32.11
        for <linux-mm@kvack.org>;
        Mon, 07 Mar 2016 09:32:11 -0800 (PST)
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
References: <1456951177-23579-1-git-send-email-khalid.aziz@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56DDBB18.6030505@intel.com>
Date: Mon, 7 Mar 2016 09:32:08 -0800
MIME-Version: 1.0
In-Reply-To: <1456951177-23579-1-git-send-email-khalid.aziz@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, davem@davemloft.net, corbet@lwn.net, akpm@linux-foundation.org, dingel@linux.vnet.ibm.com, zhenzhang.zhang@huawei.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, arnd@arndb.de, sparclinux@vger.kernel.org
Cc: rob.gardner@oracle.com, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, luto@kernel.org, ebiederm@xmission.com, bsegall@google.com, geert@linux-m68k.org, dave@stgolabs.net, adobriyan@gmail.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On 03/02/2016 12:39 PM, Khalid Aziz wrote:
> --- a/include/uapi/asm-generic/siginfo.h
> +++ b/include/uapi/asm-generic/siginfo.h
> @@ -206,7 +206,10 @@ typedef struct siginfo {
>  #define SEGV_MAPERR	(__SI_FAULT|1)	/* address not mapped to object */
>  #define SEGV_ACCERR	(__SI_FAULT|2)	/* invalid permissions for mapped object */
>  #define SEGV_BNDERR	(__SI_FAULT|3)  /* failed address bound checks */
> -#define NSIGSEGV	3
> +#define SEGV_ACCADI	(__SI_FAULT|4)	/* ADI not enabled for mapped object */
> +#define SEGV_ADIDERR	(__SI_FAULT|5)	/* Disrupting MCD error */
> +#define SEGV_ADIPERR	(__SI_FAULT|6)	/* Precise MCD exception */
> +#define NSIGSEGV	6

FYI, this will conflict with code in -tip right now:

> http://git.kernel.org/cgit/linux/kernel/git/tip/tip.git/commit/?h=mm/pkeys&id=cd0ea35ff5511cde299a61c21a95889b4a71464e

It's not a big deal to resolve, of course.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
