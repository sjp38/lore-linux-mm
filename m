Date: Tue, 10 Jul 2007 09:12:17 -0700
From: Bill Irwin <bill.irwin@oracle.com>
Subject: Re: [RFC][PATCH] hugetlbfs read support
Message-ID: <20070710161217.GX26380@holomorphy.com>
References: <1184009291.31638.8.camel@dyn9047017100.beaverton.ibm.com> <20070710153752.GV26380@holomorphy.com> <20070710154312.GE27655@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070710154312.GE27655@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Bill Irwin <bill.irwin@oracle.com>, Badari Pulavarty <pbadari@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>, clameter@sgi.com, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On 10.07.2007 [08:37:52 -0700], Bill Irwin wrote:
>> What's the testing status of all this? I thoroughly approve of the
>> concept, of course.

On Tue, Jul 10, 2007 at 08:43:12AM -0700, Nishanth Aravamudan wrote:
> With this change, OProfile is able to do symbol lookup (which is
> achieved via libbfd, which does reads() of the appropriate files) with
> relinked binaries in post-processing. The file utility is also able to
> recognize persistent text segments as ELF executables.
> If you would like further testing, let me know what.

That's good enough for me.

Acked-by: William Irwin <bill.irwin@oracle.com>


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
