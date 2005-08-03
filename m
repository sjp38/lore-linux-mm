From: Daniel Phillips <phillips@istop.com>
Subject: Re: Network vm deadlock... solution?
Date: Wed, 3 Aug 2005 10:55:09 +1000
References: <200508020654.32693.phillips@istop.com> <20050802214340.GA6309@electric-eye.fr.zoreil.com> <16580000.1123022344@[10.10.2.4]>
In-Reply-To: <16580000.1123022344@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508031055.09787.phillips@istop.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Francois Romieu <romieu@fr.zoreil.com>, Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 03 August 2005 08:39, Martin J. Bligh wrote:
> --Francois Romieu <romieu@fr.zoreil.com> wrote (on Tuesday, August 02, 2005 
> > Btw I do not get what the mempool/GFP_CRITICAL idea buys: it seems
> > redundant with the threshold ("if (memory_pressure)") used in the Rx path
> > to decide that memory is low.
>
> It's send-side, not receive.

Receive side.  Send side also needs reserve+throttling but it is easier 
because we flag packets at allocation time for special handling.

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
