Date: Thu, 03 Apr 2003 08:49:55 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH 2.5.66-mm2] Fix page_convert_anon locking issues
Message-ID: <92070000.1049381395@[10.1.1.5]>
In-Reply-To: <116640000.1049327888@baldur.austin.ibm.com>
References: <8910000.1049303582@baldur.austin.ibm.com>
 <20030402132939.647c74a6.akpm@digeo.com>
 <80300000.1049320593@baldur.austin.ibm.com>
 <20030402150903.21765844.akpm@digeo.com>
 <102170000.1049325787@baldur.austin.ibm.com>
 <20030402153845.0770ef54.akpm@digeo.com>
 <110950000.1049326945@baldur.austin.ibm.com>
 <20030402155220.651a1005.akpm@digeo.com>
 <116640000.1049327888@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--On Wednesday, April 02, 2003 17:58:08 -0600 Dave McCracken
<dmccr@us.ibm.com> wrote:

> It's looking more and more like we should use your other suggestion.  It's
> definitely simpler if we can make it failsafe.  I'll code it up tomorrow.

I thought of a big hole in the simpler scheme you suggested.  It occurred
to me that try_to_unmap will fail.  It will see the PageAnon flag so it'll
just walk the pte_chain and assume it doesn't have to walk the vmas.  This
will leave the page with some stranded mappings.  Actually
page_convert_anon will then finish, and we'll have a page where
try_to_unmap claims it has succeeded but still has mappings.

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
