Date: Sun, 29 Jun 2003 08:45:12 -0400 (EDT)
From: Zwane Mwaikambo <zwane@linuxpower.ca>
Subject: Re: 2.5.73-mm2
In-Reply-To: <20030628231113.GZ26348@holomorphy.com>
Message-ID: <Pine.LNX.4.53.0306290844120.1878@montezuma.mastecende.com>
References: <20030627202130.066c183b.akpm@digeo.com> <20030628155436.GY20413@holomorphy.com>
 <20030628160013.46a5b537.akpm@digeo.com> <20030628231113.GZ26348@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 28 Jun 2003, William Lee Irwin III wrote:

> On Sat, Jun 28, 2003 at 04:00:13PM -0700, Andrew Morton wrote:
> > What architectures has this been tested on?
> 
> i386 only, CONFIG_HIGHMEM64G with various combinations of highpte &
> highpmd, and nohighmem. No CONFIG_HIGHMEM4G or non-i386 machines that
> can run 2.5.x are within my grasp (obviously CONFIG_HIGHMEM4G machines
> could, I just don't have them, and the discontig code barfs on mem=).

It comes up fine on a CONFIG_HIGHMEM4G (16G) box.

-- 
function.linuxpower.ca
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
