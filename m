Message-ID: <3D5D0CC5.768BEAE8@zip.com.au>
Date: Fri, 16 Aug 2002 07:31:33 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] add buddyinfo /proc entry
References: <3D5C6410.1020706@us.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> 
> ..
> +static void frag_stop(struct seq_file *m, void *arg)
> +{
> +       (void)m;
> +       (void)arg;
> +}

Don't tell me the compiler warns about this now?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
