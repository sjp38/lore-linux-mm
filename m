Date: Wed, 23 Apr 2003 23:39:54 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: 2.5.68-mm2
Message-ID: <20030423233954.D9036@redhat.com>
References: <20030423012046.0535e4fd.akpm@digeo.com><18400000.1051109459@[10.10.2.4]> <20030423144648.5ce68d11.akpm@digeo.com> <1565150000.1051134452@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1565150000.1051134452@flay>; from mbligh@aracnet.com on Wed, Apr 23, 2003 at 02:47:32PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2003 at 02:47:32PM -0700, Martin J. Bligh wrote:
> The performance improvement was about 25% of systime according to my 
> measurements - I don't call that insignificant.

Never, ever use changes in system time as a justification for a patch.  We 
all know that Linux's user/system time accounting is patently unreliable.  
Remember Nyquist?  Talk to me about differences in wall clock and your 
comments will be more interesting.

		-ben
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
