Date: Tue, 15 Oct 2002 11:01:47 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: Compiler Error with ENOTSUP
Message-ID: <2068275763.1034679707@[10.10.2.3]>
In-Reply-To: <OF66118521.9D9B2989-ON85256C53.0062571F@pok.ibm.com>
References: <OF66118521.9D9B2989-ON85256C53.0062571F@pok.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Wong <wpeter@us.ibm.com>, akpm@zip.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--On Tuesday, October 15, 2002 1:01 PM -0500 Peter Wong <wpeter@us.ibm.com> wrote:

> I encountered a compiler error when I was building 2.5.42 with
> Andrew's mm3 patch.
> 
> In include/linux/ext2_xattr.h and include/linux/ext3_xattr.h,
> ENOTSUP is returned in many places. It should be ENOTSUPP as
>       ^                                                ^^
> defined in include/linux/errno.h.
> 
> Regards,
> Peter
> 
> Peter Wai Yee Wong
> IBM LTC Performance Team
> email: wpeter@us.ibm.com
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
