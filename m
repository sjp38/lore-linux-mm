From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH v2] Linux VM workaround for Knights Landing A/D leak
Date: Tue, 14 Jun 2016 13:54:25 -0700
Message-ID: <eccd473b-d3d6-3fe2-69c2-69b69729f721@zytor.com>
References: <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com>
 <1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com>
 <57603DC0.9070607@linux.intel.com>
 <20160614193407.1470d998@lxorguk.ukuu.org.uk>
 <576052E0.3050408@linux.intel.com> <20160614191916.GI30015@pd.tnic>
 <4b2c481e-35ae-1cd6-ca58-1535bfef346c@zytor.com>
 <20160614204736.GL30015@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160614204736.GL30015@pd.tnic>
Sender: linux-kernel-owner@vger.kernel.org
To: Borislav Petkov <bp@alien8.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org, harish.srinivasappa@intel.com, lukasz.odzioba@intel.com, grzegorz.andrejczuk@intel.com, lukasz.daniluk@intel.com
List-Id: linux-mm.kvack.org

On 06/14/16 13:47, Borislav Petkov wrote:
> On Tue, Jun 14, 2016 at 01:20:06PM -0700, H. Peter Anvin wrote:
>> static_cpu_has_bug() should turn into 5-byte NOP in the common (bugless)
>> case.
> 
> Yeah, it does. I looked at the asm.
> 
> I wasn't 100% sure because I vaguely remember gcc reordering things in
> some pathological case but I'm most likely remembering wrong because if
> it were doing that, then the whole nopping out won't work. F'get about
> it. :)
> 

There was that.  It is still possible that we end up with NOP a JMP
right before another JMP; we could perhaps make the patching code
smarter and see if we have a JMP immediately after.

	-hpa
