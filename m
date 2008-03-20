Date: Wed, 19 Mar 2008 21:04:36 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [1/2] vmalloc: Show vmalloced areas via /proc/vmallocinfo
Message-ID: <20080319210436.191bb8fe@laptopd505.fenrus.org>
In-Reply-To: <20080318222827.291587297@sgi.com>
References: <20080318222701.788442216@sgi.com>
	<20080318222827.291587297@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Mar 2008 15:27:02 -0700
Christoph Lameter <clameter@sgi.com> wrote:

> Implement a new proc file that allows the display of the currently
> allocated vmalloc memory.

> +	proc_create("vmallocinfo",S_IWUSR|S_IRUGO, NULL,


why should non-root be able to read this? sounds like a security issue (info leak) to me...




-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
