Date: Fri, 16 Aug 2002 14:03:11 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] add buddyinfo /proc entry
Message-ID: <20020816210311.GY15685@holomorphy.com>
References: <3D5C6410.1020706@us.ibm.com> <3D5D0CC5.768BEAE8@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D5D0CC5.768BEAE8@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
+static void frag_stop(struct seq_file *m, void *arg)
+{
+       (void)m;
+       (void)arg;
+}

On Fri, Aug 16, 2002 at 07:31:33AM -0700, Andrew Morton wrote:
> Don't tell me the compiler warns about this now?

Woops -- that's actually a wli dropping. Some (?) of my code was
borrowed for this. Someone pounded -Werror into my head too hard
at school or something.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
