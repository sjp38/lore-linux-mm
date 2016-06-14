From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH v2] Linux VM workaround for Knights Landing A/D leak
Date: Tue, 14 Jun 2016 14:13:48 -0700
Message-ID: <B9213B85-0761-42BB-B546-60E92ABAC13A@zytor.com>
References: <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com> <1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com> <57603DC0.9070607@linux.intel.com> <20160614193407.1470d998@lxorguk.ukuu.org.uk> <576052E0.3050408@linux.intel.com> <20160614191916.GI30015@pd.tnic> <4b2c481e-35ae-1cd6-ca58-1535bfef346c@zytor.com> <20160614204736.GL30015@pd.tnic> <eccd473b-d3d6-3fe2-69c2-69b69729f721@zytor.com> <20160614210255.GM30015@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160614210255.GM30015@pd.tnic>
Sender: linux-kernel-owner@vger.kernel.org
To: Borislav Petkov <bp@alien8.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org, harish.srinivasappa@intel.com, lukasz.odzioba@intel.com, grzegorz.andrejczuk@intel.com, lukasz.daniluk@intel.com
List-Id: linux-mm.kvack.org

On June 14, 2016 2:02:55 PM PDT, Borislav Petkov <bp@alien8.de> wrote:
>On Tue, Jun 14, 2016 at 01:54:25PM -0700, H. Peter Anvin wrote:
>> There was that.  It is still possible that we end up with NOP a JMP
>> right before another JMP; we could perhaps make the patching code
>> smarter and see if we have a JMP immediately after.
>
>Yeah, I still can't get reproduce that reliably - I remember seeing it
>at some point but then dismissing it for another, higher-prio thing.
>And
>now the whole memory is hazy at best.
>
>But, you're giving me a great idea right now - I have this kernel
>disassembler tool which dumps alternative sections already and I could
>teach it to look for pathological cases around the patching sites and
>scream.
>
>Something for my TODO list when I get a quiet moment.
>
>Thanks!

We talked with the GCC people about always bias asm goto toward the first label even if followed by __builtin_unreachable().  I don't know if that happened; if so we should probably insert the unreachable for those versions of gcc only.
-- 
Sent from my Android device with K-9 Mail. Please excuse brevity and formatting.
