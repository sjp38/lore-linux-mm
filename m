From: Alistair John Strachan <s0348365@sms.ed.ac.uk>
Subject: Re: Kernel BUG at mm/rmap.c:491
Date: Wed, 23 Nov 2005 23:35:15 +0000
References: <200511232256.jANMuGg20547@unix-os.sc.intel.com> <cone.1132788250.534735.25446.501@kolivas.org>
In-Reply-To: <cone.1132788250.534735.25446.501@kolivas.org>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200511232335.15050.s0348365@sms.ed.ac.uk>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <con@kolivas.org>
Cc: Kenneth W <kenneth.w.chen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wednesday 23 November 2005 23:24, Con Kolivas wrote:
> Chen, Kenneth W writes:
> > Has people seen this BUG_ON before?  On 2.6.15-rc2, x86-64.
> >
> > Pid: 16500, comm: cc1 Tainted: G    B 2.6.15-rc2 #3
> >
> > Pid: 16651, comm: sh Tainted: G    B 2.6.15-rc2 #3
>
>                        ^^^^^^^^^^
>
> Please try to reproduce it without proprietary binary modules linked in.

AFAIK "G" means all loaded modules are GPL, P is for proprietary modules.

FWIW, I reported a similarly located BUG() in this file (line 487 in 2.6.14) a 
couple of weeks ago. I believe there is a problem lurking somewhere.

-- 
Cheers,
Alistair.

'No sense being pessimistic, it probably wouldn't work anyway.'
Third year Computer Science undergraduate.
1F2 55 South Clerk Street, Edinburgh, UK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
