From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 01/10] x86_64: Cleanup non-smp usage of cpu maps v2
Date: Mon, 7 Apr 2008 23:32:55 +0200
Message-ID: <20080407213255.GA30765@elte.hu>
References: <20080325220650.835342000@polaris-admin.engr.sgi.com> <20080325220651.011213000@polaris-admin.engr.sgi.com> <20080326064045.GF18301@elte.hu> <47FA85E4.5010005@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757038AbYDGVdY@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <47FA85E4.5010005@sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Mike Travis <travis@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <clameter@sgi.com>
List-Id: linux-mm.kvack.org


* Mike Travis <travis@sgi.com> wrote:

> How about something like the below? (I haven't tried compiling it 
> yet.)

looks good to me - the closer it is to the real API, the better.

	Ingo
