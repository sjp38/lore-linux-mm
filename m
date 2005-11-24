Date: Wed, 23 Nov 2005 23:40:10 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: Kernel BUG at mm/rmap.c:491
Message-ID: <20051124044009.GE30849@redhat.com>
References: <200511232256.jANMuGg20547@unix-os.sc.intel.com> <cone.1132788250.534735.25446.501@kolivas.org> <200511232335.15050.s0348365@sms.ed.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200511232335.15050.s0348365@sms.ed.ac.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alistair John Strachan <s0348365@sms.ed.ac.uk>
Cc: Con Kolivas <con@kolivas.org>, Kenneth W <kenneth.w.chen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 23, 2005 at 11:35:15PM +0000, Alistair John Strachan wrote:
 > On Wednesday 23 November 2005 23:24, Con Kolivas wrote:
 > > Chen, Kenneth W writes:
 > > > Has people seen this BUG_ON before?  On 2.6.15-rc2, x86-64.
 > > >
 > > > Pid: 16500, comm: cc1 Tainted: G    B 2.6.15-rc2 #3
 > > >
 > > > Pid: 16651, comm: sh Tainted: G    B 2.6.15-rc2 #3
 > >
 > >                        ^^^^^^^^^^
 > >
 > > Please try to reproduce it without proprietary binary modules linked in.
 > 
 > AFAIK "G" means all loaded modules are GPL, P is for proprietary modules.


The 'G' seems to confuse a hell of a lot of people.
(I've been asked about it when people got machine checks a lot over
 the last few months).

Would anyone object to changing it to conform to the style of
the other taint flags ? Ie, change it to ' ' ?

		Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
