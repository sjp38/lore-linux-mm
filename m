From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Only process_die notifier in ia64_do_page_fault if KPROBES is configured.
Date: Tue, 30 Aug 2005 03:08:44 +0200
References: <200508262246.j7QMkEoT013490@linux.jf.intel.com> <200508270224.26423.ak@suse.de> <20050830001905.GA18279@linux.jf.intel.com>
In-Reply-To: <20050830001905.GA18279@linux.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508300308.44706.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rusty Lynch <rusty@linux.intel.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Rusty Lynch <rusty.lynch@intel.com>, linux-mm@kvack.org, prasanna@in.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, anil.s.keshavamurthy@intel.com
List-ID: <linux-mm.kvack.org>

On Tuesday 30 August 2005 02:19, Rusty Lynch wrote:

>
> So, assuming inlining the notifier_call_chain would address Christoph's
> conserns, is the following patch something like what you are sugesting?

Yes.

Well in theory you could make fast and slow notify_die too, but that's
probably not worth it.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
