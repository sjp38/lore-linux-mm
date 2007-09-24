Date: Mon, 24 Sep 2007 19:24:23 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH 1/1] x86: Convert cpuinfo_x86 array to a per_cpu array
	v3
Message-ID: <20070924232423.GJ8127@redhat.com>
References: <20070924210853.256462000@sgi.com> <20070924210853.516791000@sgi.com> <46F833D4.8050507@tiscali.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46F833D4.8050507@tiscali.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: roel <12o3l@tiscali.nl>
Cc: travis@sgi.com, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

<excessive quoting trimmed, please don't quote 40K of text
 to add a single line reply>

On Tue, Sep 25, 2007 at 12:01:56AM +0200, roel wrote:

 > > --- a/arch/i386/kernel/cpu/cpufreq/powernow-k6.c
 > > +++ b/arch/i386/kernel/cpu/cpufreq/powernow-k6.c
 > > @@ -215,7 +215,7 @@ static struct cpufreq_driver powernow_k6
 > >   */
 > >  static int __init powernow_k6_init(void)
 > >  {
 > > -	struct cpuinfo_x86      *c = cpu_data;
 > > +	struct cpuinfo_x86 *c = &cpu_data(0);
 > >  
 > >  	if ((c->x86_vendor != X86_VENDOR_AMD) || (c->x86 != 5) ||
 > >  		((c->x86_model != 12) && (c->x86_model != 13)))
 > 
 > while we're at it, we could change this to
 > 
 >   	if (!(c->x86_vendor == X86_VENDOR_AMD && c->x86 == 5 &&
 >   		(c->x86_model == 12 || c->x86_model == 13)))

For what purpose?  There's nothing wrong with the code as it stands,
and inverting the tests means we'd have to move a bunch of
code inside the if arm instead of just returning -ENODEV.

	Dave

-- 
http://www.codemonkey.org.uk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
