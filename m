Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 434B46B002C
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 19:02:37 -0500 (EST)
Date: Wed, 7 Mar 2012 19:02:33 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: decode GFP flags in oom killer output.
Message-ID: <20120308000233.GA10695@redhat.com>
References: <20120307233939.GB5574@redhat.com>
 <op.watq2ixr3l0zgt@mpn-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <op.watq2ixr3l0zgt@mpn-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, Mar 08, 2012 at 12:48:08AM +0100, Michal Nazarewicz wrote:
 
 > > +static void decode_gfp_mask(gfp_t gfp_mask, char *out_string)
 > > +{
 > > +	unsigned int i;
 > > +
 > > +	for (i = 0; i < 32; i++) {
 > > +		if (gfp_mask & (1 << i)) {
 > > +			if (gfp_flag_texts[i])
 > > +				out_string += sprintf(out_string, "%s ", gfp_flag_texts[i]);
 > > +			else
 > > +				out_string += sprintf(out_string, "reserved! ");
 > > +		}
 > > +	}
 > > +	out_string = "\0";
 > 
 > Uh?  Did you mean a??*out_string = 0;a?? which is redundant anyway?

Yeah, that was the intent.
 
 > Also, this leaves a trailing space at the end of the string.

The zero was supposed to wipe it out, but I just realized it's advanced past it.
 
 > >  static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 > >  			struct mem_cgroup *memcg, const nodemask_t *nodemask)
 > >  {
 > > +	char gfp_string[80];
 > 
 > For ~0, the string will be 256 characters followed by a NUL byte byte at the end.
 > This combination may make no sense, but the point is that you need to take length
 > of the buffer into account, probably by using snprintf() and a counter.

alternatively, we could just use a bigger buffer here.

thanks,

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
