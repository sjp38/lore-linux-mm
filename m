From: Andi Kleen <ak@suse.de>
Subject: Re: Apply type enum zone_type
Date: Sat, 5 Aug 2006 03:38:47 +0200
References: <Pine.LNX.4.64.0608041646550.5573@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0608041654380.5573@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608041654380.5573@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200608050338.47642.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Saturday 05 August 2006 01:55, Christoph Lameter wrote:
> After we have done this we can now do some typing cleanup.
> 
> The memory policy layer keeps a policy_zone that specifies
> the zone that gets memory policies applied. This variable
> can now be of type enum zone_type.
> 
> The check_highest_zone function and the build_zonelists funnctionm must
> then also take a enum zone_type parameter.
> 
> Plus there are a number of loops over zones that also should use
> zone_type.
> 
> We run into some troubles at some points with functions that need a
> zone_type variable to become -1. Fix that up.

enums are not really type checked, so it seems somewhat pointless
to do this change.

If you really wanted strict type checking you would need typedef struct
and accessors.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
