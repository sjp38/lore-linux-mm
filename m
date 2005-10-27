From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Date: Thu, 27 Oct 2005 10:38:51 +0200
References: <1130366995.23729.38.camel@localhost.localdomain>
In-Reply-To: <1130366995.23729.38.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200510271038.52277.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, andrea@suse.de, Jeff Dike <jdike@addtoit.com>, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thursday 27 October 2005 00:49, Badari Pulavarty wrote:

>
> I would really appreciate your comments on my approach.

(from a high level point of view) It sounds very scary. Traditionally
a lot of code had special case handling to avoid truncate
races, and it might need a lot of auditing to make sure
everybode else can handle arbitary punch hole too.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
